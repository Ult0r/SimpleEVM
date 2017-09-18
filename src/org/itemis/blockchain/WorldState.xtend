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
import org.itemis.utils.Utils
import org.itemis.types.UnsignedByte
import org.itemis.ressources.MainnetAllocData
import org.itemis.evm.utils.MerklePatriciaTrie
import org.itemis.utils.db.DataBaseWrapper
import org.itemis.utils.db.DataBaseWrapper.DataBaseID

class WorldState {
  extension Utils u = new Utils
  extension DataBaseWrapper db = new DataBaseWrapper

  private final static String INSERT_ACCOUNT_STMT = "INSERT INTO accounts VALUES (?, ?, ?, ?, ?, ?)"
  
  private final String name
  
  new(String name) {
    this.name = name
  }

  def initTables() {
    val conn = DataBaseID.STATE.getConnection(name)
    conn.createTable("accounts", "(address BINARY(32) PRIMARY KEY, nonce BINARY(32) NOT NULL, balance BINARY(32) NOT NULL, storageRoot BINARY(32) NOT NULL, codeHash BINARY(32) NOT NULL, code LONGVARCHAR)")
    conn.createTable("storage", "(account BINARY(32), offset BINARY(32), value BINARY(32), PRIMARY KEY (account, offset))")
    conn.close
  }

  def loadGenesisState() {
    val conn = DataBaseID.STATE.getConnection(name)
    
    val stmt = conn.prepareStatement(INSERT_ACCOUNT_STMT)
    
    val zero = new EVMWord(0)
    val emptyRoot = new EVMWord(new MerklePatriciaTrie.Null().hash.elements, true)
    
    val iter = MainnetAllocData.mainnetAllocDataQueryIterator
    while(iter.hasNext) {
      val e = iter.next
      
      stmt.setBytes(1, e.key.toByteArray(true))
      stmt.setBytes(2, zero.toByteArray(true))
      stmt.setBytes(3, e.value.toByteArray(true))
      stmt.setBytes(4, emptyRoot.toByteArray(true))
      stmt.setBytes(5, keccak256("").toByteArray(true))
      stmt.setString(6, null)
      stmt.executePreparedStatement
    }
    
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
