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

import org.itemis.utils.Utils
import org.itemis.types.UnsignedByte
import org.itemis.types.Nibble
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.Map
import org.itemis.types.NibbleList
import org.itemis.evm.utils.MerklePatriciaTrie.Branch
import org.itemis.evm.utils.MerklePatriciaTrie.Node
import org.itemis.evm.utils.MerklePatriciaTrie.UnsignedByteList
import org.itemis.types.EVMWord
import org.itemis.utils.StaticUtils

class MerklePatriciaTrie {
  private final String name
  @Accessors private Node root = new Null
  private MerklePatriciaTrieCache cache
  @Accessors private boolean keepIntermediates = true
  
  new(String name) {
    this(name, 32, 140)
  }

  new(String name, int maxPrefixLength, int maxDataLength) {
    this.name = name
    this.cache = new MerklePatriciaTrieCache(name, maxPrefixLength, maxDataLength)
  }
  
  def EVMWord getTrieRoot() {
    val _root = root.hash
    if(_root.size < 32) {
      StaticUtils.keccak256(_root.elements.map[byteValue])
    } else {
      new EVMWord(_root.elements, true)
    }
  }

  def void putElement(NibbleList key, UnsignedByte[] value) {
    root = root.putElement(this, key, value)
  }

  def String toGraphViz() {
    String.format("digraph G {\n%s}", root.toGraphViz(this, "  ROOT"))
  }
  
  def void flush() {
    cache.flush
  }

  static abstract class Node {
    protected extension Utils u = new Utils
    protected extension EVMUtils e = new EVMUtils

    def abstract UnsignedByteList hash()

    def UnsignedByteList hashFromRLP(List<UnsignedByte> rlp) {
      new UnsignedByteList(
        if(rlp.size < 32) {
          rlp
        } else {
          keccak256(rlp.map[byteValue]).toByteArray
        }
      )
    }

    // overrides existent value
    def abstract Node putElement(MerklePatriciaTrie trie, NibbleList key, UnsignedByte[] value)

    def abstract String toGraphViz(MerklePatriciaTrie trie, String prefix)
    
    def static Node fromTwoKeyValuePairs(MerklePatriciaTrie trie, NibbleList firstKey, UnsignedByte[] firstValue,
      NibbleList secondKey, UnsignedByte[] secondValue) {
      if(firstKey.length == 0 && secondKey.length == 0) {
        throw new IllegalArgumentException("can't build a node out of two empty keys")
      }

      val sharedPrefix = firstKey.sharedPrefix(secondKey)

      if(sharedPrefix.length == 0) { // branch -> leaf / leaf
        val branchMap = newHashMap
        var UnsignedByte[] branchValue = null

        if(firstKey.length != 0) {
          val firstLeaf = new Leaf(trie, firstKey.tail, firstValue)
          branchMap.put(firstKey.head, firstLeaf.hash)
        } else {
          branchValue = firstValue
        }

        if(secondKey.length != 0) {
          val secondLeaf = new Leaf(trie, secondKey.tail, secondValue)
          branchMap.put(secondKey.head, secondLeaf.hash)
        } else {
          branchValue = secondValue
        }

        new Branch(trie, branchMap, branchValue)
      } else { // extension -> branch -> leaf / leaf
        val branch = Node.fromTwoKeyValuePairs(
          trie,
          firstKey.subList(sharedPrefix.length),
          firstValue,
          secondKey.subList(sharedPrefix.length),
          secondValue
        )

        new Extension(trie, sharedPrefix, branch.hash)
      }
    }
  }

  static class Null extends Node {
    // static: "0x56E81F171BCC55A6FF8345E692C0F86E5B48E01B996CADC001622FB5E363B421"
    override hash() {
      val arr = newByteArrayOfSize(0).map[new UnsignedByte(it)]
      new UnsignedByteList(keccak256(rlp(arr as UnsignedByte[]).map[byteValue]).toByteArray)
    }

    override putElement(MerklePatriciaTrie trie, NibbleList key, UnsignedByte[] value) {
      new Leaf(trie, key, value)
    }

    override toGraphViz(MerklePatriciaTrie trie, String prefix) {
      prefix + 'NULL [label="NULL"];\n'
    }
  }

  static class Leaf extends Node {
    // it can be assumed that encodedPath is always of even length
    // given that it's padded for odd lengths
    @Accessors
    private NibbleList encodedPath = new NibbleList
    @Accessors
    private UnsignedByte[] value
  
    new() {
      
    }

    new(MerklePatriciaTrie trie, NibbleList key, UnsignedByte[] value) {
      if(key.length % 2 == 0) {
        encodedPath.add(new Nibble(0x2))
        encodedPath.add(new Nibble(0x0))
      } else {
        encodedPath.add(new Nibble(0x3))
      }
      encodedPath.addAll(key)
      this.value = value

      trie.cache.putNode(this)
    }

    override hash() {
      val List<UnsignedByte[]> list = newArrayList
      list.add(encodedPath.toUnsignedBytes)
      list.add(value)
      val rlp = rlp(list)

      super.hashFromRLP(rlp)
    }

    override putElement(MerklePatriciaTrie trie, NibbleList key, UnsignedByte[] value) {
      var int offset = 1
      if(encodedPath.get(0).byteValue != 3) {
        offset = 2
      }

      val thisKey = encodedPath.subList(offset)

      if(thisKey.equals(key)) {
        this.value = value
        this
      } else {
        if (!trie.keepIntermediates) {
          trie.cache.removeNode(this)
        }
        Node.fromTwoKeyValuePairs(trie, thisKey, this.value, key, value)
      }
    }

    override toGraphViz(MerklePatriciaTrie trie, String prefix) {
      String.format(
        '%s [shape=box label="{%s,%s}"];\n',
        prefix,
//        encodedPath.toString.substring(4, Math.min(7, encodedPath.toString.length))
        encodedPath.toString,
//        encodedPath.toString.substring({if (encodedPath.get(0).byteValue != 3) 4 else 3}),
        value.toHex
      )
    }
  }

  static class Extension extends Node {
    // it can be assumed that encodedPath is always of even length
    // given that it's padded for odd lengths
    @Accessors
    private NibbleList encodedPath = new NibbleList
    @Accessors
    private UnsignedByteList nextKey
  
    new() {
      
    }

    new(MerklePatriciaTrie trie, NibbleList path, UnsignedByteList key) {
      if(path.length == 0) {
        System.err.println(key.elements.toHex)
      }
      if(path.length % 2 == 0) {
        encodedPath.add(new Nibble(0x0))
        encodedPath.add(new Nibble(0x0))
      } else {
        encodedPath.add(new Nibble(0x1))
      }
      encodedPath.addAll(path)
      this.nextKey = key

      trie.cache.putNode(this)
    }

    override hash() {
//      println("extension#hash")
      val List<UnsignedByte[]> list = newArrayList
      list.add(encodedPath.toUnsignedBytes as UnsignedByte[])
      list.add(nextKey.elements)
      val rlp = rlp(list, [it.size >= 32 || !it.isValidRLP])

      super.hashFromRLP(rlp)
    }

    def private encodedPathOffset() {
      if(encodedPath.get(0).value == 0x1) {
        1
      } else {
        2
      }
    }

    override putElement(MerklePatriciaTrie trie, NibbleList key, UnsignedByte[] value) {
      if (!trie.keepIntermediates) {
        trie.cache.removeNode(this)
      }
      
      val thisKey = encodedPath.subList(encodedPathOffset)

      if(key.startsWith(thisKey)) { // extension -> branch
        var Node child = trie.cache.lookUp(this.nextKey)
        child = child.putElement(trie, key.unsharedSuffix(thisKey), value)
        nextKey = child.hash
        trie.cache.putNode(this)
        this
      } else {
        val sharedPrefix = thisKey.sharedPrefix(key)

        if(sharedPrefix.length == 0) { // branch -> extension
          var branchMap = newHashMap
          var UnsignedByte[] branchValue = null

          if(thisKey.length == 1) {
            branchMap.put(thisKey.head, nextKey)
          } else {
            val newExtension = new Extension(trie, thisKey.tail, this.nextKey)
            branchMap.put(thisKey.head, newExtension.hash)
          }

          if(key.length == 0) {
            branchValue = value
          } else {
            val newLeaf = new Leaf(trie, key.tail, value)
            branchMap.put(key.head, newLeaf.hash)
          }

          new Branch(trie, branchMap, branchValue)
        } else { // extension -> branch -> extension
          val suffix = thisKey.unsharedSuffix(key)

          var UnsignedByteList bottom = null
          if(suffix.tail.length == 0) {
            bottom = nextKey
          } else {
            val bottomExtension = new Extension(trie, suffix.tail, nextKey)
            bottom = bottomExtension.hash
          }

          var branchMap = newHashMap
          branchMap.put(suffix.head, bottom)
          val branch = new Branch(trie, branchMap, null)
          branch.putElement(trie, key.unsharedSuffix(thisKey), value)

          val topExtension = new Extension(trie, sharedPrefix, branch.hash)
          topExtension
        }
      }
    }

    override toGraphViz(MerklePatriciaTrie trie, String prefix) {
      String.format(
        '%s [shape=ellipse label="%s"];\n%s -> %s_EXTENSION;\n%s',
        prefix,
        toHex(encodedPath.toUnsignedBytes),
        prefix,
        prefix,
        trie.cache.lookUp(nextKey).toGraphViz(trie, prefix + "_EXTENSION")
      )
    }
  }

  static class Branch extends Node {
    @Accessors
    private List<UnsignedByteList> paths = newArrayList
    @Accessors
    private UnsignedByte[] value
  
    new() {
      
    }

    new(MerklePatriciaTrie trie, Map<Nibble, UnsignedByteList> entries, UnsignedByte[] value) {
      for (i : 0 .. 15) {
        paths.add(null)
      }

      for (e : entries.entrySet) {
        paths.set(e.key.intValue, e.value)
      }
      this.value = value
      trie.cache.putNode(this)
    }

    override hash() {
      val List<UnsignedByte[]> list = newArrayList
      list.addAll(paths.map [
        if(it === null) {
          #[] as UnsignedByte[]
        } else {
          it.elements as UnsignedByte[]
        }
      ])
      list.add({
        if(value === null) {
          #[] as UnsignedByte[]
        } else {
          value
        }
      })

      val rlp = rlp(list, [it.size >= 32 || !it.isValidRLP || it.equals(value)])
      super.hashFromRLP(rlp)
    }

    override putElement(MerklePatriciaTrie trie, NibbleList key, UnsignedByte[] value) {
      if (!trie.keepIntermediates) {
        trie.cache.removeNode(this)
      }
      
      if(key.length == 0) {
        this.value = value
      } else {
        val child = trie.cache.lookUp(this.paths.get(key.head.intValue))
        if(child === null) {
          val leaf = new Leaf(trie, key.tail, value)
          this.paths.set(key.head.intValue, leaf.hash)
        } else {
          this.paths.set(key.head.intValue, child.putElement(trie, key.tail, value).hash)
        }
      }

      trie.cache.putNode(this)
      this
    }

    override toGraphViz(MerklePatriciaTrie trie, String prefix) {
      var StringBuilder result = new StringBuilder()

      result.append(String.format(
        '%s [shape=house label="%s"];\n',
        prefix,
        value?.toHex()
      ))

      for (i : 0 .. 15) {
        var child = trie.cache.lookUp(paths.get(i))

        if(child !== null) {
          val asHex = toHex(new Nibble(i))
          result.append(String.format(
            '%s -> %s_BRANCH_%s [label="%s"];\n%s',
            prefix,
            prefix,
            asHex,
            asHex,
            child.toGraphViz(trie, prefix + "_BRANCH_" + asHex)
          ))
        }
      }

      result.toString
    }
  }

  static class UnsignedByteList {
    @Accessors private List<UnsignedByte> elements = newArrayList

    new(UnsignedByte[] array) {
      this.elements.addAll(array)
    }

    override equals(Object other) {
      if(other instanceof UnsignedByteList) {
        if(size == other.size) {
          for (var i = 0; i < size; i++) {
            if(!get(i).equals(other.get(i))) {
              return false
            }
          }
          return true
        } else {
          return false
        }
      } else {
        return false
      }
    }

    override hashCode() {
      elements.hashCode
    }

    def UnsignedByte get(int i) {
      elements.get(i)
    }

    def int size() {
      elements.size
    }
  }
}
