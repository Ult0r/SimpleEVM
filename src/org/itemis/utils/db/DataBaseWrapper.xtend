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

import java.sql.Connection
import java.io.File
import java.sql.DriverManager
import java.sql.ResultSet
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import java.sql.Statement
import java.sql.PreparedStatement
import java.util.Map
import org.itemis.utils.ShutdownSequence
import org.apache.commons.io.FileUtils

final class DataBaseWrapper {
  private final static Logger LOGGER = LoggerFactory.getLogger("Database")
  
  private final static boolean shutdownHookAdded = {
    ShutdownSequence.registerShutdownClass(DataBaseWrapper, 20)
    true
  }

  public enum DataBaseID {
    STATE,
    ALLOC,
    TRIE,
    CHAINDATA
  }

  private final static String OPTIONS = ";shutdown=true" + ";hsqldb.default_table_type=cached" + ""

  private final static String STATE_LOCATION     = "db" + File.separator + "state" + File.separator + "%s" + File.separator + "_" + OPTIONS
  private final static String ALLOC_LOCATION     = "db" + File.separator + "alloc" + File.separator + "%s" + File.separator + "_" + OPTIONS
  private final static String TRIE_LOCATION      = "db" + File.separator + "trie" + File.separator + "%s" + File.separator + "_" + OPTIONS
  private final static String CHAINDATA_LOCATION = "db" + File.separator + "chaindata" + File.separator + "%s" + File.separator + "_" + OPTIONS

  private final static Map<Pair<DataBaseID, String>, Connection> connections = newHashMap
  
  def static File getLocation(DataBaseID db, String dbName) {
    new File(System.getProperty("user.dir") + File.separator + switch (db) {
      case STATE: String.format(STATE_LOCATION, dbName, dbName)
      case ALLOC: String.format(ALLOC_LOCATION, dbName, dbName)
      case TRIE: String.format(TRIE_LOCATION, dbName, dbName)
      case CHAINDATA: String.format(CHAINDATA_LOCATION, dbName, dbName)
    }.split(";").get(0).split('\\\\').reverseView.drop(1).toList.reverseView.join('\\\\'))
  }

  def static Connection getConnection(DataBaseID db, String dbName) {
    if (connections.containsKey(Pair.of(db, dbName))) {
      connections.get(Pair.of(db, dbName))
    } else {
      LOGGER.debug("connecting to '" + dbName + "' of type " + db.toString)
      val conn = DriverManager.getConnection("jdbc:hsqldb:file:" + switch (db) {
        case STATE: String.format(STATE_LOCATION, dbName, dbName)
        case ALLOC: String.format(ALLOC_LOCATION, dbName, dbName)
        case TRIE: String.format(TRIE_LOCATION, dbName, dbName)
        case CHAINDATA: String.format(CHAINDATA_LOCATION, dbName, dbName)
      })
      conn.autoCommit = true
      connections.put(Pair.of(db, dbName), conn)
      conn
    }
  }
  
  def static void shutdown() {
    if (shutdownHookAdded) {
      closeAllConnections
    }
  }

  def static void closeAllConnections() {
    val list = connections.entrySet.toList.map[key].toList
    for (conn : list) {
      closeConnection(conn.key, conn.value)
    }
    connections.clear
  }

  def static void closeConnection(DataBaseID db, String dbName) {
    val conn = connections.get(Pair.of(db, dbName))
    LOGGER.debug("closing '" + dbName + "' of type " + db.toString)
    if(conn !== null) {
      try {
        conn.createStatement().execute("SHUTDOWN")
      } catch(Exception e) {
        LOGGER.info("shutdown query failed: " + e.message)
      }
      conn.commit
      conn.close
    }
    connections.remove(Pair.of(db, dbName))
  }

  def boolean createTable(DataBaseID db, String dbName, String name, String fields) {
    createTable(db, dbName, name + " " + fields)
  }

  def boolean createTable(DataBaseID db, String dbName, String table) {
    val conn = getConnection(db, dbName)
    val result = createTable(conn, table)
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
      if(!e.message.contains("object name already exists")) {
        LOGGER.warn("failed to create table: " + table + ": " + e.message)
      }
      false
    }
  }

  def ResultSet query(DataBaseID db, String dbName, String query) {
    val conn = getConnection(db, dbName)
    val result = query(conn, query)
    result
  }

  def ResultSet query(Connection conn, String query) {
    try {
//      LOGGER.info("trying to execute query: " + query)
      val statement = conn.createStatement()
      val hasResult = statement.execute(query)
      if(hasResult) statement.resultSet
    } catch(Exception e) {
      if(!e.message.contains("integrity constraint violation")) {
        LOGGER.info("query failed: " + e.message)
      }
      null
    }
  }

  def void executeBatch(DataBaseID db, String dbName, Statement batch) {
    val conn = getConnection(db, dbName)
    executeBatch(conn, batch)
  }

  def void executeBatch(Connection conn, Statement batch) {
    try {
//      LOGGER.info("trying to execute batch: " + batch.toString)
      batch.executeBatch
    } catch(Exception e) {
      if(!e.message.contains("integrity constraint violation")) {
        LOGGER.info("batch failed: " + e.message)
      }
    }
  }

  def PreparedStatement createPreparedStatement(Connection conn, String query) {
    try {
      conn.prepareStatement(query)
    } catch(Exception e) {
      LOGGER.error("preparing statement failed: " + e.message)
      null
    }
  }

  def ResultSet executePreparedStatement(PreparedStatement stmt) {
    try {
//      LOGGER.info("trying to execute prepared statement")
      stmt.execute
      stmt.resultSet
    } catch(Exception e) {
      if(!e.message.contains("integrity constraint violation")) {
        LOGGER.info("prepared statement failed: " + e.message)
      }
      null
    }
  }
  
  def void deleteDB(DataBaseID dbType, String dbName) {
    closeConnection(dbType, dbName)
    FileUtils.deleteDirectory(getLocation(dbType, dbName))
  }
  
  def ResultSet copyDB(DataBaseID dbType, String dbName, String newName) {
    query(dbType, dbName, String.format("BACKUP DATABASE TO '%s/' BLOCKING AS FILES", getLocation(dbType, newName).absolutePath.replace("\\", "/")))
  }
}
