package org.itemis.utils.db

import com.google.common.cache.LoadingCache
import com.google.common.cache.CacheBuilder
import com.google.common.cache.CacheLoader
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

final class TwoLevelDBCache<K, V> {
  extension DataBaseWrapper db = new DataBaseWrapper

  private final static Logger LOGGER = LoggerFactory.getLogger("Trie")

  private final String dbName
  private final DataBaseID dbType
  private final List<String> dbTables
  private final LoadingCache<K, V> firstLevelCache
  private final DBBufferCache<K, V> secondLevelCache
  
  private final Function<Connection, PreparedStatement> getInsertStatement
  private final Function<Triple<K, V, PreparedStatement>, PreparedStatement> fillInsertStatement
  private final Function<Connection, PreparedStatement> getSelectStatement
  private final Function<Pair<K, PreparedStatement>, PreparedStatement> fillSelectStatement
  private final Function<Pair<ResultSet, K>, V> parseSelectResult
  private final Function<Connection, PreparedStatement> getDeleteStatement
  private final Function<Triple<K, V, PreparedStatement>, PreparedStatement> fillDeleteStatement
  
  private boolean databaseCreated = false
  private boolean flushing = false
  
  new(int maxCacheSize, int writeCacheSize, DataBaseID dbType, String dbName, List<String> dbTables,
    String getInsertStatement,
    Function<Triple<K, V, PreparedStatement>, PreparedStatement> fillInsertStatement,
    String getSelectStatement,
    Function<Pair<K, PreparedStatement>, PreparedStatement> fillSelectStatement,
    Function<Pair<ResultSet, K>, V> parseSelectResult,
    String getDeleteStatement,
    Function<Triple<K, V, PreparedStatement>, PreparedStatement> fillDeleteStatement) {
      this(
        maxCacheSize,
        writeCacheSize,
        dbType,
        dbName,
        dbTables,
        new Function<Connection, PreparedStatement>() {
         override apply(Connection t) {
            t.prepareStatement(getInsertStatement)
          }
        },
        fillInsertStatement,
        new Function<Connection, PreparedStatement>() {
         override apply(Connection t) {
            t.prepareStatement(getSelectStatement)
          }
        },
        fillSelectStatement,
        parseSelectResult,
        new Function<Connection, PreparedStatement>() {
         override apply(Connection t) {
            t.prepareStatement(getDeleteStatement)
          }
        },
        fillDeleteStatement
      )
    }

  new(int maxCacheSize, int writeCacheSize, DataBaseID dbType, String dbName, List<String> dbTables,
    Function<Connection, PreparedStatement> getInsertStatement,
    Function<Triple<K, V, PreparedStatement>, PreparedStatement> fillInsertStatement,
    Function<Connection, PreparedStatement> getSelectStatement,
    Function<Pair<K, PreparedStatement>, PreparedStatement> fillSelectStatement,
    Function<Pair<ResultSet, K>, V> parseSelectResult,
    Function<Connection, PreparedStatement> getDeleteStatement,
    Function<Triple<K, V, PreparedStatement>, PreparedStatement> fillDeleteStatement) {
    this.dbName = dbName
    this.dbType = dbType
    this.dbTables = dbTables
    this.secondLevelCache = new DBBufferCache(this, writeCacheSize)
    this.firstLevelCache = CacheBuilder.newBuilder().maximumSize(maxCacheSize).removalListener(secondLevelCache).build(
      new CacheLoader<K, V>() {
        override load(K key) throws Exception {
          // TODO
          throw new UnsupportedOperationException("I don't know what this does")
        }
      }
    )
    
    this.getInsertStatement = getInsertStatement
    this.fillInsertStatement = fillInsertStatement
    this.getSelectStatement = getSelectStatement
    this.fillSelectStatement = fillSelectStatement
    this.parseSelectResult = parseSelectResult
    this.getDeleteStatement = getDeleteStatement
    this.fillDeleteStatement = fillDeleteStatement
  }

  def V lookUp(K key) {
    if(key !== null) firstLevelCache.getIfPresent(key) ?: secondLevelCache.checkWriteCache(key) ?: readValueFromDB(key) 
  }
  
  def void put(K key, V value) {
    if (!databaseCreated) {
      createDatabase
    }
    
    flushing = false
    firstLevelCache.put(key, value)
  }

  def void remove(K key) {
    firstLevelCache.invalidate(key)
  }

  def void flush() {
    LOGGER.debug(firstLevelCache.size.toString)
    if (!databaseCreated) {
      createDatabase
    }
    var conn = dbType.getConnection(dbName)
    conn.query("SET FILES LOG FALSE")
    conn.commit
    conn.autoCommit = false
    val stmt = getInsertStatement.apply(conn) 
    for (n: firstLevelCache.asMap.entrySet.toList) {
      fillInsertStatement.apply(Triple.of(n.key, n.value, stmt))
    }
    conn.commit
    conn.query("SET FILES LOG TRUE")
    conn.commit
    conn.close
    flushing = true
    firstLevelCache.invalidateAll
    firstLevelCache.cleanUp
    secondLevelCache.flushWriteCache
  }
  
  private def void createDatabase() {
    for (table : dbTables) {
      dbType.createTable(dbName, table)
    }

    databaseCreated = true
  }
  
  protected def void writeValueToDB(K key, V value) {
    writeValueToDB(dbType.getConnection(dbName), key, value)
  }
  
  protected def void writeValueToDB(Connection conn, K key, V value) {
    writeValueToDB(getInsertStatement.apply(conn), key, value)
  }
  
  protected def void writeValueToDB(PreparedStatement stmt, K key, V value) {
    try {
      val _stmt = fillInsertStatement.apply(Triple.of(key, value, stmt))
      _stmt.executePreparedStatement
    } catch (Exception e) {
      LOGGER.trace(e.message)
    }
  }

  protected def V readValueFromDB(K key) {
    readValueFromDB(dbType.getConnection(dbName), key)
  }
  
  protected def V readValueFromDB(Connection conn, K key) {
    readValueFromDB(getSelectStatement.apply(conn), key)
  }
  
  protected def V readValueFromDB(PreparedStatement stmt, K key) {
    try {
      val _stmt = fillSelectStatement.apply(Pair.of(key, stmt))
      parseSelectResult.apply(Pair.of(_stmt.executePreparedStatement, key))
    } catch (Exception e) {
      LOGGER.trace(e.message)
      null
    }
  }
  
  protected def void removeValueFromDB(K key, V value) {
    removeValueFromDB(dbType.getConnection(dbName), key, value)
  }
  
  protected def void removeValueFromDB(Connection conn, K key, V value) {
    removeValueFromDB(getDeleteStatement.apply(conn), key, value)
  }
  
  protected def void removeValueFromDB(PreparedStatement stmt, K key, V value) {
    try {
      val _stmt = fillDeleteStatement.apply(Triple.of(key, value, stmt))
      _stmt.executePreparedStatement
    } catch (Exception e) {
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
      writeCache.add(notification)
      if(!firstLevelCache.flushing && writeCache.size > writeCacheSize) {
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
      LOGGER.debug(writeCache.size.toString)
      val conn = DataBaseID.TRIE.getConnection(firstLevelCache.dbName)
      conn.query("SET FILES LOG FALSE")
      conn.commit
      conn.autoCommit = false
      var stmt = firstLevelCache.getInsertStatement.apply(conn)
      
      val iter = writeCache.iterator
      while (iter.hasNext) {
        val n = iter.next
        firstLevelCache.writeValueToDB(stmt, n.key, n.value)
      }
      conn.commit
      writeCache.clear
      conn.query("SET FILES LOG TRUE")
      conn.commit
      conn.close
    }
  }
}
