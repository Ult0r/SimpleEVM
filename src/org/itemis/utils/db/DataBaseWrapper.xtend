package org.itemis.utils.db

import java.sql.Connection
import java.io.File
import java.sql.DriverManager
import java.sql.ResultSet
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import java.sql.Statement
import org.itemis.types.EVMWord
import java.sql.PreparedStatement

final class DataBaseWrapper {
  private final static Logger LOGGER = LoggerFactory.getLogger("Database")
  
  public enum DataBaseID {
    STATE,
    ALLOC,
    TRIE
  }
  
  private final static String OPTIONS =
    ";shutdown=true" +
    ";hsqldb.default_table_type=cached" +
    ""
  
  private final static String STATE_LOCATION = "db" + File.separator + "state" + File.separator + "%s" + File.separator + "%s" + OPTIONS
  private final static String ALLOC_LOCATION = "db" + File.separator + "alloc" + File.separator + "%s" + File.separator + "%s" + OPTIONS
  private final static String TRIE_LOCATION  = "db" + File.separator + "trie"  + File.separator + "%s" + File.separator + "%s" + OPTIONS
  
  def Connection getConnection(DataBaseID db, String dbName) {
//    LOGGER.debug("accessing db " + db)
    val conn = DriverManager.getConnection("jdbc:hsqldb:file:" + switch (db) {
      case STATE: String.format(STATE_LOCATION, dbName, dbName)
      case ALLOC: String.format(ALLOC_LOCATION, dbName, dbName)
      case TRIE:  String.format(TRIE_LOCATION, dbName, dbName)
    })
    
    conn.autoCommit = true
    conn
  }
  
  def boolean createTable(DataBaseID db, String dbName, String name, String fields) {
    createTable(db, dbName, name + " " + fields)
  }
  
  def boolean createTable(DataBaseID db, String dbName, String table) {
    val conn = getConnection(db, dbName)
    val result = createTable(conn, table)
    conn.close
    result 
  }
  
  def boolean createTable(Connection conn, String name, String fields) {
    createTable(conn, name + " " + fields)
  }
  
  def boolean createTable(Connection conn, String table) {
    try {
      LOGGER.info("trying to create table: " + table) 
      conn.createStatement.execute(
        String.format("CREATE TABLE %s", table)
      )
      true
    } catch(Exception e) {
      if (!e.message.contains("object name already exists")) {
        LOGGER.warn("failed to create table: " + table + ": " + e.message)
      }
      false
    }
  }
  
  def ResultSet query(DataBaseID db, String dbName, String query) {
    val conn = getConnection(db, dbName)
    val result = query(conn, query)
    conn.close
    result 
  }
  
  def ResultSet query(Connection conn, String query) {
    try {
//      LOGGER.debug("trying to execute query: " + query)
      val statement = conn.createStatement()
      val hasResult = statement.execute(query)
      if (hasResult) statement.resultSet
    } catch(Exception e) {
      if (!e.message.contains("integrity constraint violation")) {
        LOGGER.info("query failed: " + e.message)
      }
      null
    }
  }
  
  def void executeBatch(DataBaseID db, String dbName, Statement batch) {
    val conn = getConnection(db, dbName)
    executeBatch(conn, batch)
    conn.close
  }
  
  def void executeBatch(Connection conn, Statement batch) {
    try {
//      LOGGER.debug("trying to execute batch: " + batch.toString)
      batch.executeBatch
    } catch(Exception e) {
      if (!e.message.contains("integrity constraint violation")) {
        LOGGER.info("batch failed: " + e.message)
      }
    }
  }
  
  def ResultSet executePreparedStatement(PreparedStatement stmt) {
    try {
//      LOGGER.debug("trying to execute prepared statement")
      stmt.execute
      stmt.resultSet
    } catch (Exception e) {
      if (!e.message.contains("integrity constraint violation")) {
        LOGGER.info("prepared statement failed: " + e.message)
      }
      null
    }
  }
  
  def String formatForQuery(EVMWord word) {
    word.toHexString.substring(2)
  }
}