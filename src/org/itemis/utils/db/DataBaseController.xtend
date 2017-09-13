package org.itemis.utils.db

import java.sql.Connection
import java.io.File
import java.sql.DriverManager
import java.sql.ResultSet
import java.util.Map
import org.slf4j.Logger
import org.slf4j.LoggerFactory

final class DataBaseController {
  private final static Logger LOGGER = LoggerFactory.getLogger("Database")
  
  public enum DataBaseID {
    STATE,
    ALLOC,
    TRIE
  }
  
  private final static String STATE_LOCATION = "db" + File.separator + "state" + File.separator + "state"
  private final static String ALLOC_LOCATION = "db" + File.separator + "alloc" + File.separator + "alloc"
  private final static String TRIE_LOCATION  = "db" + File.separator + "trie" + File.separator + "trie"
  
  private static Map<DataBaseID, Connection> CONNECTIONS = {
    val result = newHashMap
    
    LOGGER.info("opening connection to " + STATE_LOCATION)
    result.put(DataBaseID.STATE, DriverManager.getConnection("jdbc:hsqldb:file:" + STATE_LOCATION, "SA", ""))
    LOGGER.info("opening connection to " + ALLOC_LOCATION)
    result.put(DataBaseID.ALLOC, DriverManager.getConnection("jdbc:hsqldb:file:" + ALLOC_LOCATION, "SA", ""))
    LOGGER.info("opening connection to " + TRIE_LOCATION)
    result.put(DataBaseID.TRIE,  DriverManager.getConnection("jdbc:hsqldb:file:" + TRIE_LOCATION, "SA", ""))
    
    for (conn: result.entrySet.toList.map[it.value]) {
      conn.autoCommit = true
    }
    
    result
  }
  
  def private Connection getConnection(DataBaseID db) {
    LOGGER.debug("accessing db " + db)
    CONNECTIONS.get(db)
  }
  
  def boolean createTable(DataBaseID db, String name, String fields) {
    val conn = getConnection(db)
    try {
      LOGGER.info("trying to create table: " + name + " " + fields) 
      conn.prepareStatement(
        String.format("CREATE TABLE %s %s", name, fields)
      ).execute
      true
    } catch(Exception e) {
      LOGGER.warn("failed to create table") 
      false
    }
  }
  
  def ResultSet query(DataBaseID db, String query) {
    val conn = getConnection(db)
    try {
      LOGGER.debug("trying to execute query: " + query)
      val statement = conn.prepareStatement(query)
      val hasResult = statement.execute
      if (hasResult) statement.resultSet
    } catch(Exception e) {
      LOGGER.info("query failed: " + e.message)
      null
    }
  }
}