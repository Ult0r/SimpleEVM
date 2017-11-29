/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.utils.db

import com.google.common.cache.CacheBuilder
import com.google.common.cache.RemovalListener
import org.itemis.utils.db.DataBaseWrapper
import java.util.List
import com.google.common.cache.RemovalNotification
import java.util.ArrayList
import org.itemis.utils.db.DataBaseWrapper.DataBaseID
import org.slf4j.LoggerFactory
import org.slf4j.Logger
import java.sql.PreparedStatement
import org.apache.commons.lang3.tuple.Triple
import java.util.function.Function
import java.sql.Connection
import java.sql.ResultSet
import com.google.common.cache.Cache
import org.itemis.utils.Shutdownable
import org.itemis.utils.ShutdownSequence
import java.io.File

final class TwoLevelDBCache<K, V> implements Shutdownable {
  extension DataBaseWrapper db = new DataBaseWrapper

  private final static Logger LOGGER = LoggerFactory.getLogger("Trie")

  private final String dbName
  private final DataBaseID dbType
  private final String dbTable
  private final Cache<K, V> firstLevelCache
  private final DBBufferCache<K, V> secondLevelCache

  private final PreparedStatement insertStatement
  private final Function<Triple<K, V, PreparedStatement>, PreparedStatement> fillInsertStatement
  private final PreparedStatement selectStatement
  private final Function<Pair<K, PreparedStatement>, PreparedStatement> fillSelectStatement
  private final Function<Pair<ResultSet, K>, V> parseSelectResult
  private final PreparedStatement deleteStatement
  private final Function<Pair<K, PreparedStatement>, PreparedStatement> fillDeleteStatement

  private boolean flushing = false
  
  new(int maxCacheSize, DataBaseID dbType, String dbName, String dbTable, String insertStatement,
    Function<Triple<K, V, PreparedStatement>, PreparedStatement> fillInsertStatement, String selectStatement,
    Function<Pair<K, PreparedStatement>, PreparedStatement> fillSelectStatement,
    Function<Pair<ResultSet, K>, V> parseSelectResult, String deleteStatement,
    Function<Pair<K, PreparedStatement>, PreparedStatement> fillDeleteStatement) {
    this(
      maxCacheSize,
      Math.max(maxCacheSize / 10, 50),
      dbType,
      dbName,
      dbTable,
      insertStatement,
      fillInsertStatement,
      selectStatement,
      fillSelectStatement,
      parseSelectResult,
      deleteStatement,
      fillDeleteStatement
    )
  }

  new(int maxCacheSize, int writeCacheSize, DataBaseID dbType, String dbName, String dbTable, String insertStatement,
    Function<Triple<K, V, PreparedStatement>, PreparedStatement> fillInsertStatement, String selectStatement,
    Function<Pair<K, PreparedStatement>, PreparedStatement> fillSelectStatement,
    Function<Pair<ResultSet, K>, V> parseSelectResult, String deleteStatement,
    Function<Pair<K, PreparedStatement>, PreparedStatement> fillDeleteStatement) {
    this.dbName = dbName
    this.dbType = dbType
    this.dbTable = dbTable
    this.secondLevelCache = new DBBufferCache(this, writeCacheSize)
    this.firstLevelCache = CacheBuilder.newBuilder().maximumSize(maxCacheSize).removalListener(secondLevelCache).build()

    createDatabase

    this.insertStatement = DataBaseWrapper.getConnection(dbType, dbName).createPreparedStatement(insertStatement)
    this.fillInsertStatement = fillInsertStatement
    this.selectStatement = DataBaseWrapper.getConnection(dbType, dbName).createPreparedStatement(selectStatement)
    this.fillSelectStatement = fillSelectStatement
    this.parseSelectResult = parseSelectResult
    this.deleteStatement = DataBaseWrapper.getConnection(dbType, dbName).createPreparedStatement(deleteStatement)
    this.fillDeleteStatement = fillDeleteStatement
    
    ShutdownSequence.registerShutdownInstance(this)
  }
  
  def File getLocation() {
    DataBaseWrapper.getLocation(dbType, dbName)
  }

  def V lookUp(K key) {
    if(key !== null) firstLevelCache.getIfPresent(key) ?: secondLevelCache.checkWriteCache(key) ?: readValueFromDB(key)
  }

  def void put(K key, V value) {
    flushing = false
    firstLevelCache.put(key, value)
  }

  def void remove(K key) {
    firstLevelCache.invalidate(key)
  }

  def void flush() {
    var conn = DataBaseWrapper.getConnection(dbType, dbName)
    conn.query("SET FILES LOG FALSE")
    conn.commit
    conn.autoCommit = false
    for (n : firstLevelCache.asMap.entrySet.toList) {
      insertStatement.writeValueToDB(n.key, n.value)
    }
    conn.commit
    conn.query("SET FILES LOG TRUE")
    conn.commit
    conn.autoCommit = true
    flushing = true
    firstLevelCache.cleanUp
    secondLevelCache.flushWriteCache
  }

  private def void createDatabase() {
    dbType.createTable(dbName, dbTable)
  }

  protected def void writeValueToDB(K key, V value) {
    writeValueToDB(DataBaseWrapper.getConnection(dbType, dbName), key, value)
  }

  protected def void writeValueToDB(Connection conn, K key, V value) {
    writeValueToDB(insertStatement, key, value)
  }

  protected def void writeValueToDB(PreparedStatement stmt, K key, V value) {
    try {
      val _stmt = fillInsertStatement.apply(Triple.of(key, value, stmt))
      _stmt.executePreparedStatement
    } catch(Exception e) {
      LOGGER.trace(e.message)
    }
  }

  protected def V readValueFromDB(K key) {
    readValueFromDB(DataBaseWrapper.getConnection(dbType, dbName), key)
  }

  protected def V readValueFromDB(Connection conn, K key) {
    readValueFromDB(selectStatement, key)
  }

  protected def V readValueFromDB(PreparedStatement stmt, K key) {
    try {
      val _stmt = fillSelectStatement.apply(Pair.of(key, stmt))
      parseSelectResult.apply(Pair.of(_stmt.executePreparedStatement, key))
    } catch(Exception e) {
      LOGGER.trace(e.message)
      null
    }
  }

  protected def void removeValueFromDB(K key) {
    removeValueFromDB(DataBaseWrapper.getConnection(dbType, dbName), key)
  }

  protected def void removeValueFromDB(Connection conn, K key) {
    removeValueFromDB(deleteStatement, key)
  }

  protected def void removeValueFromDB(PreparedStatement stmt, K key) {
    try {
      val _stmt = fillDeleteStatement.apply(Pair.of(key, stmt))
      _stmt.executePreparedStatement
    } catch(Exception e) {
      LOGGER.trace(e.message)
    }
  }

  protected static final class DBBufferCache<K, V> implements RemovalListener<K, V> {
    extension DataBaseWrapper db = new DataBaseWrapper

    private final TwoLevelDBCache<K, V> firstLevelCache
    private final int writeCacheSize
    private final List<RemovalNotification<K, V>> writeCache

    new(TwoLevelDBCache<K, V> firstLevelCache, int writeCacheSize) {
      this.firstLevelCache = firstLevelCache
      this.writeCacheSize = writeCacheSize
      this.writeCache = new ArrayList(writeCacheSize)
    }

    override onRemoval(RemovalNotification<K, V> notification) {
//      if (!firstLevelCache.flushing) {
      writeCache.add(notification)
//      }
      if(writeCache.size > writeCacheSize) {
        this.flushWriteCache
      }
    }

    def V checkWriteCache(K hash) {
      for (n : writeCache) {
        if(n.key.equals(hash)) {
          return n.value
        }
      }
      null
    }

    def void flushWriteCache() {
      val conn = DataBaseWrapper.getConnection(firstLevelCache.dbType, firstLevelCache.dbName)
      conn.query("SET FILES LOG FALSE")
      conn.commit
      conn.autoCommit = false

      val iter = writeCache.iterator
      while(iter.hasNext) {
        val n = iter.next
        firstLevelCache.writeValueToDB(firstLevelCache.insertStatement, n.key, n.value)
      }
      conn.commit
      writeCache.clear
      conn.query("SET FILES LOG TRUE")
      conn.commit
      conn.autoCommit = true
    }
  }
  
  override shutdown() {
    flush()
  }
}
