package org.itemis.utils.db

import java.sql.Connection
import java.io.File
import java.sql.DriverManager
import org.itemis.utils.logging.LoggerController
import java.sql.ResultSet
import java.util.Map

final class DataBaseController {
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
    
    result.put(DataBaseID.STATE, DriverManager.getConnection("jdbc:hsqldb:file:" + STATE_LOCATION, "SA", ""))
    result.put(DataBaseID.ALLOC, DriverManager.getConnection("jdbc:hsqldb:file:" + ALLOC_LOCATION, "SA", ""))
    result.put(DataBaseID.TRIE,  DriverManager.getConnection("jdbc:hsqldb:file:" + TRIE_LOCATION, "SA", ""))
    
    for (conn: result.entrySet.toList.map[it.value]) {
      conn.autoCommit = true
    }
    
    result
  }
  
  def private Connection getConnection(DataBaseID db) {
    LoggerController.logInfo(DataBaseController, "getConnection", "accessing db " + db)
    CONNECTIONS.get(db)
  }
  
  def boolean createTable(DataBaseID db, String name, String fields) {
    val conn = getConnection(db)
    try {
      LoggerController.logInfo(DataBaseController, "createTable", "trying to create table: " + name + " " + fields)
      conn.prepareStatement(
        String.format("CREATE TABLE %s %s", name, fields)
      ).execute
      true
    } catch(Exception e) {
      LoggerController.logWarning(DataBaseController, "createTable", "failed to create table")
      false
    }
  }
  
  def ResultSet query(DataBaseID db, String query) {
    val conn = getConnection(db)
    try {
      LoggerController.logInfo(DataBaseController, "query", "trying to execute query: " + query)
      val statement = conn.prepareStatement(query)
      val hasResult = statement.execute
      if (hasResult) statement.resultSet
    } catch(Exception e) {
      LoggerController.logWarning(DataBaseController, "query", "query failed: " + e.message)
      null
    }
  }
}