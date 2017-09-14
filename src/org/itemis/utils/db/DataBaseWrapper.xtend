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
  
  private final static String STATE_LOCATION = "db" + File.separator + "state" + File.separator + "state" + ";shutdown=true"
  private final static String ALLOC_LOCATION = "db" + File.separator + "alloc" + File.separator + "alloc" + ";shutdown=true"
  private final static String TRIE_LOCATION  = "db" + File.separator + "trie" + File.separator + "trie" + ";shutdown=true"
  
  def Connection getConnection(DataBaseID db) {
    LOGGER.debug("accessing db " + db)
    val conn = DriverManager.getConnection("jdbc:hsqldb:file:" + switch (db) {
      case STATE: STATE_LOCATION,
      case ALLOC: ALLOC_LOCATION,
      case TRIE:  TRIE_LOCATION
    })
    
    conn.autoCommit = true
    conn
  }
  
  def boolean createTable(DataBaseID db, String name, String fields) {
    val conn = getConnection(db)
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
    val conn = getConnection(db)
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
    val conn = getConnection(db)
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