package org.itemis.utils.db

import java.sql.Connection
import java.io.File
import java.sql.DriverManager
import java.sql.ResultSet
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import java.sql.Statement
import org.itemis.types.EVMWord

final class DataBaseWrapper {
  private final static Logger LOGGER = LoggerFactory.getLogger("Database")
  
  public enum DataBaseID {
    STATE,
    ALLOC,
    TRIE
  }
  
  private final static String STATE_LOCATION = "db" + File.separator + "state" + File.separator + "%s" + File.separator + "%s" + ";shutdown=true"
  private final static String ALLOC_LOCATION = "db" + File.separator + "alloc" + File.separator + "%s" + File.separator + "%s" + ";shutdown=true"
  private final static String TRIE_LOCATION  = "db" + File.separator + "trie"  + File.separator + "%s" + File.separator + "%s" + ";shutdown=true"
  
  private def String defaultName(DataBaseID db) {
    switch (db) {
      case STATE: "state"
      case ALLOC: "alloc"
      case TRIE:  "trie"
    }
  }
  
  def Connection getConnection(DataBaseID db) {
    getConnection(db, defaultName(db))
  }
  
  def Connection getConnection(DataBaseID db, String dbName) {
    LOGGER.debug("accessing db " + db)
    val conn = DriverManager.getConnection("jdbc:hsqldb:file:" + switch (db) {
      case STATE: String.format(STATE_LOCATION, dbName, dbName),
      case ALLOC: String.format(ALLOC_LOCATION, dbName, dbName),
      case TRIE:  String.format(TRIE_LOCATION, dbName, dbName)
    })
    
    conn.autoCommit = true
    conn
  }
  
  def boolean createTable(DataBaseID db, String name, String fields) {
    createTable(db, defaultName(db), name, fields)
  }
  
  def boolean createTable(DataBaseID db, String dbName, String name, String fields) {
    val conn = getConnection(db, dbName)
    val result = createTable(conn, name, fields)
    conn.close
    result 
  }
  
  def boolean createTable(Connection conn, String name, String fields) {
    try {
      LOGGER.info("trying to create table: " + name + " " + fields) 
      conn.createStatement.execute(
        String.format("CREATE TABLE %s %s", name, fields)
      )
      true
    } catch(Exception e) {
      LOGGER.warn("failed to create table: " + name + " " + fields)
      false
    }
  }
  
  def ResultSet query(DataBaseID db, String query) {
    query(db, defaultName(db), query)
  }
  
  def ResultSet query(DataBaseID db, String dbName, String query) {
    val conn = getConnection(db, dbName)
    val result = query(conn, query)
    conn.close
    result 
  }
  
  def ResultSet query(Connection conn, String query) {
    try {
      LOGGER.debug("trying to execute query: " + query)
      val statement = conn.createStatement()
      val hasResult = statement.execute(query)
      if (hasResult) statement.resultSet
    } catch(Exception e) {
      LOGGER.info("query failed: " + e.message)
      null
    }
  }
  
  def void executeBatch(DataBaseID db, Statement batch) {
    executeBatch(db, defaultName(db), batch)
  }
  
  def void executeBatch(DataBaseID db, String dbName, Statement batch) {
    val conn = getConnection(db, dbName)
    executeBatch(conn, batch)
    conn.close
  }
  
  def void executeBatch(Connection conn, Statement batch) {
    try {
      LOGGER.debug("trying to execute batch")
      batch.executeBatch
    } catch(Exception e) {
      LOGGER.info("batch failed: " + e.message)
    }
  }
  
  def String formatForQuery(EVMWord word) {
    word.toHexString.substring(2)
  }
}