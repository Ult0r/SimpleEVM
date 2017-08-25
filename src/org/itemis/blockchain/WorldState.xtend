/*******************************************************************************
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
* 
* Contributors:
* Lars Reimers for itemis AG
*******************************************************************************/
package org.itemis.blockchain

import org.itemis.types.EVMWord
import java.sql.Connection
import java.sql.DriverManager
import org.itemis.utils.Utils
import org.itemis.utils.logging.LoggerController
import org.itemis.types.UnsignedByte
import org.itemis.ressources.MainnetAllocData
import java.io.File

class WorldState {
  extension Utils u = new Utils
  
  private static String EMPTY_EVMWORD = new EVMWord(0).toHexString.substring(2)

  private Connection conn

  new(String name) {
    LoggerController.logInfo(WorldState, "new(String)", "accessing state at " + name)

    val _path = "ressources" + File.separator + name
    _path.ensureDirExists

    conn = DriverManager.getConnection(
      "jdbc:hsqldb:file:" + _path + File.separator + name,
      "SA",
      ""
    )
  }

  def initTables() {
    try {
      val st = conn.createStatement
      st.addBatch(
        "CREATE TABLE accounts (address BINARY(32) PRIMARY KEY, nonce BINARY(32) NOT NULL, balance BINARY(32) NOT NULL, storageRoot BINARY(32) NOT NULL, codeHash BINARY(32) NOT NULL, code LONGVARCHAR)"
      )
      st.addBatch(
        "CREATE TABLE storage (account BINARY(32), offset BINARY(32), value BINARY(32), PRIMARY KEY (account, offset))"
      )
      st.executeBatch
      st.close
    } catch (Exception e) {
      LoggerController.logSevere(WorldState, "initTables", "failed to initialize")
      throw e
    }
  }
  
  def initAccount(EVMWord address, EVMWord balance) {
    try {
      val query = String.format(
        "INSERT INTO accounts VALUES ('%s', '%s', '%s', '%s', '%s', %s)",
        address.toHexString.substring(2),
        EMPTY_EVMWORD,
        balance.toHexString.substring(2),
        EMPTY_EVMWORD, //TODO: storageRoot
        EMPTY_EVMWORD, //TODO: codeHash
        "null"
      )
      conn.prepareStatement(query).execute
    } catch (Exception e) {
      LoggerController.logSevere(WorldState, "initAccount", "failed to initialize " + address.toHexString)
      throw e
    }
  }

  def loadGenesisState() {
    for (e: MainnetAllocData.mainnetAllocDataMap.entrySet.toList) {
      initAccount(e.key, e.value)
    }
  }
  
  def close() {
    conn.close
  }

  def Account getAccountAt(EVMWord address) {
    
  }
  
  def UnsignedByte[] getCodeAt(EVMWord address) {
    
  }
  
  def EVMWord getStorageAt(EVMWord address, EVMWord offset) {
    
  }

  def setAccountAt(EVMWord address, Account acc) {
    
  }

  def setCodeAt(EVMWord address, UnsignedByte[] acc) {
    
  }
}
