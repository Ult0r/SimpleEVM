/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.evm.utils

import org.itemis.utils.db.DataBaseWrapper.DataBaseID
import org.itemis.types.NibbleList
import java.util.ArrayList
import java.sql.PreparedStatement
import org.itemis.utils.db.TwoLevelDBCache
import org.apache.commons.lang3.tuple.Triple
import java.sql.ResultSet
import org.itemis.utils.StaticUtils
import org.itemis.types.UnsignedByte
import org.itemis.types.impl.EVMWord
import org.itemis.evm.utils.MerklePatriciaTrie.Node
import org.itemis.evm.utils.MerklePatriciaTrie.Null
import org.itemis.evm.utils.MerklePatriciaTrie.Leaf
import org.itemis.evm.utils.MerklePatriciaTrie.Extension
import org.itemis.evm.utils.MerklePatriciaTrie.Branch
import org.itemis.types.UnsignedByteList
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import java.io.File

class MerklePatriciaTrieCache {
  private final static Logger LOGGER = LoggerFactory.getLogger("Trie")

  private final static int MAX_CACHE_SIZE = 10000
  private final static String TABLE_STR = "nodes (hash VARBINARY(32) PRIMARY KEY, type TINYINT NOT NULL, " +
    (0 .. 15).map[String.format("v%d VARBINARY(32)", it)].join(", ") + ", prefix VARBINARY(%d), value VARBINARY(%d))"
  private final static String INSERT_STMT_STR = "INSERT INTO nodes VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
  private final static String SELECT_STMT_STR = "SELECT * FROM nodes WHERE hash=?"
  private final static String DELETE_STMT_STR = "DELETE FROM nodes WHERE hash=?"

  private final String name
  private final int maxPrefixLength
  private final int maxDataLength

  private final TwoLevelDBCache<UnsignedByteList, Node> cache

  new(String name) {
    this(name, 32)
  }

  new(String name, int maxPrefixLength) {
    this(name, maxPrefixLength, 1024)
  }

  new(String name, int maxPrefixLength, int maxDataLength) {
    this.name = name
    this.maxPrefixLength = maxPrefixLength
    this.maxDataLength = maxDataLength

    this.cache = new TwoLevelDBCache<UnsignedByteList, Node>(
      MAX_CACHE_SIZE,
      DataBaseID.TRIE,
      name,
      String.format(TABLE_STR, maxPrefixLength + 1, maxDataLength),
      INSERT_STMT_STR,
      [MerklePatriciaTrieCache::fillInsertStatement(it)],
      SELECT_STMT_STR,
      [MerklePatriciaTrieCache::fillSelectStatement(it)],
      [MerklePatriciaTrieCache::readNodeFromResultSet(it)],
      DELETE_STMT_STR,
      [MerklePatriciaTrieCache::fillDeleteStatement(it)]
    )
  }
  
  def File getLocation() {
    cache.location
  }

  def Node lookUp(UnsignedByteList hash) {
    cache.lookUp(hash)
  }

  def void putNode(Node node) {
    cache.put(node.hash, node)
  }

  def void removeNode(Node node) {
    cache.remove(node.hash)
  }

  def void flush() {
    cache.flush
  }

  private static def PreparedStatement fillInsertStatement(Triple<UnsignedByteList, Node, PreparedStatement> triple) {
    val hash = triple.left
    val node = triple.middle
    val stmt = triple.right

    val _hash = new EVMWord(hash.elements).toByteArray
    val type = switch (node) {
      Null: 0
      Leaf: 1
      Extension: 2
      Branch: 3
      default: 0
    }
    val values = switch (node) {
      Null,
      Leaf,
      Extension: newArrayList(null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null)
      Branch: node.paths.map[if(it !== null) it.elements]
    }.map[if(it !== null) it.map[byteValue]]
    val prefix = switch (node) {
      Null,
      Branch: null
      Leaf: node.encodedPath.toUnsignedBytes
      Extension: node.encodedPath.toUnsignedBytes
    }
    val value = switch (node) {
      Null: null
      Leaf: if(node.value !== null) new ArrayList<UnsignedByte>(node.value)
      Extension: node.nextKey.elements
      Branch: if(node.value !== null) new ArrayList<UnsignedByte>(node.value)
    }

    stmt.setBytes(1, _hash)
    stmt.setInt(2, type)
    for (var i = 0; i < 16; i++) {
      stmt.setBytes(i + 3, values.get(i))
    }
    stmt.setBytes(19, if(prefix !== null) prefix.map[byteValue])
    stmt.setBytes(20, if(value !== null) value.map[byteValue])

    stmt
  }

  private static def PreparedStatement fillSelectStatement(Pair<UnsignedByteList, PreparedStatement> pair) {
    val hash = pair.key
    val stmt = pair.value

    stmt.setBytes(1, new EVMWord(hash.elements).toByteArray)
    stmt
  }

  private static def PreparedStatement fillDeleteStatement(Pair<UnsignedByteList, PreparedStatement> pair) {
    val hash = pair.key
    val stmt = pair.value

    stmt.setBytes(1, new EVMWord(hash.elements).toByteArray)
    stmt
  }

  private static def Node readNodeFromResultSet(Pair<ResultSet, UnsignedByteList> pair) {
    val resultSet = pair.key
    val hash = pair.value

    try {
      resultSet.next
      val node = switch (resultSet.getInt("type")) {
        case 0: new Null()
        case 1: new Leaf()
        case 2: new Extension()
        case 3: new Branch()
      }

      switch (node) {
        Leaf: {
          val prefix = resultSet.getBytes("prefix")
          node.encodedPath = new NibbleList(StaticUtils.toNibbles(prefix.map[new UnsignedByte(it)]))
          val value = resultSet.getBytes("value")
          node.value = if(value !== null) value.map[new UnsignedByte(it)]
        }
        Extension: {
          val prefix = resultSet.getBytes("prefix")
          node.encodedPath = new NibbleList(StaticUtils.toNibbles(prefix.map[new UnsignedByte(it)]))
          val value = resultSet.getBytes("value")
          node.nextKey = new UnsignedByteList(value.map[new UnsignedByte(it)])
        }
        Branch: {
          for (var i = 0; i < 16; i++) {
            val value = resultSet.getBytes("v" + i)
            if(value !== null) {
              node.paths.add(new UnsignedByteList(value.map[new UnsignedByte(it)]))
            } else {
              node.paths.add(null)
            }
          }
          val value = resultSet.getBytes("value")
          node.value = if(value !== null) value.map[new UnsignedByte(it)]
        }
      }

      if(!node.hash.equals(hash)) {
        throw new IllegalArgumentException(String.format("hash unequal: is %s but should be %s", StaticUtils.toHex(node.hash.elements), StaticUtils.toHex(hash.elements)))
      }

      node
    } catch(Exception e) {
      LOGGER.info(e.message)
      null
    }
  }
  
  def void copyTo(String name) {
    cache.copyTo(name)
  }
  
  def void delete() {
    cache.delete
  }
}
