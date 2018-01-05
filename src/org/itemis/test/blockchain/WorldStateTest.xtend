/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.test.blockchain

import org.junit.Test
import org.itemis.blockchain.WorldState
import org.junit.Assert
import org.itemis.types.impl.EVMWord
import org.itemis.blockchain.BlockchainData
import java.math.BigInteger
import org.itemis.ressources.MainnetAllocData
import org.itemis.types.impl.Address
import org.itemis.utils.StaticUtils
import org.itemis.blockchain.Account

class WorldStateTest {
  @Test
  def void testInitWorldState() {
    val ws = new WorldState("testInitWorldState")
    ws.loadGenesisState(false)

    Assert.assertEquals(ws.accountCount, 8893)
    Assert.assertEquals(ws.stateRoot, BlockchainData.getBlockByNumber(EVMWord.ZERO).stateRoot)
    
    val iter = MainnetAllocData.mainnetAllocDataQueryIterator
    while (iter.hasNext) {
      val value = iter.next
      Assert.assertEquals(ws.getAccount(value.key).balance, value.value)
    }
  }
  
  @Test
  def void testCopy() {
    new WorldState("testCopy1").delete
    new WorldState("testCopy2").delete
    new WorldState("testCopy3").delete
    new WorldState("testCopy4").delete
    
    val ws = new WorldState("testCopy1")
    ws.loadGenesisState(false)

    Assert.assertEquals(ws.accountCount, 8893)
    Assert.assertEquals(ws.stateRoot, BlockchainData.getBlockByNumber(EVMWord.ZERO).stateRoot)
    
    ws.copyTo("testCopy2")
    val ws2 = new WorldState("testCopy2")

    Assert.assertEquals(ws2.accountCount, 8893)
    Assert.assertEquals(ws2.stateRoot, BlockchainData.getBlockByNumber(EVMWord.ZERO).stateRoot)
    
    var iter = MainnetAllocData.mainnetAllocDataQueryIterator
    while (iter.hasNext) {
      val value = iter.next
      Assert.assertEquals(ws2.getAccount(value.key).balance, value.value)
    }
    
    ws2.copyTo("testCopy3")
    val ws3 = new WorldState("testCopy3")

    Assert.assertEquals(ws3.accountCount, 8893)
    Assert.assertEquals(ws3.stateRoot, BlockchainData.getBlockByNumber(EVMWord.ZERO).stateRoot)
    
    iter = MainnetAllocData.mainnetAllocDataQueryIterator
    while (iter.hasNext) {
      val value = iter.next
      Assert.assertEquals(ws3.getAccount(value.key).balance, value.value)
    }
    
    val ws3addr = new Address(StaticUtils.fromHex("0xb19264f813465b8e6147ed011c7761c71054e91f"))
    val ws3balance = EVMWord.fromBigInteger(new BigInteger("1000000000000000000000"))
    ws3.putAccount(EVMWord.ONE, ws3addr, new Account(ws3balance))

    Assert.assertEquals(ws3.accountCount, 8894)
    
    iter = MainnetAllocData.mainnetAllocDataQueryIterator
    while (iter.hasNext) {
      val value = iter.next
      Assert.assertEquals(ws3.getAccount(value.key).balance, value.value)
    }
    Assert.assertEquals(ws3.getAccount(ws3addr).balance, ws3balance)
    
    ws3.copyTo("testCopy4")
    val ws4 = new WorldState("testCopy4")
    
    Assert.assertEquals(ws4.accountCount, 8894)
    
    iter = MainnetAllocData.mainnetAllocDataQueryIterator
    while (iter.hasNext) {
      val value = iter.next
      Assert.assertEquals(ws4.getAccount(value.key).balance, value.value)
    }
    Assert.assertEquals(ws4.getAccount(ws3addr).balance, ws3balance)
  }
  
  @Test
  def void testFirstBlock() {
    val ws = new WorldState("testFirstBlock")
    ws.loadGenesisState(false)

    val size = ws.accountCount
    val root = ws.stateRoot
    
    Assert.assertEquals(size, 8893)
    Assert.assertEquals(root, BlockchainData.getBlockByNumber(EVMWord.ZERO).stateRoot)
    
    val block = BlockchainData.getBlockByNumber(EVMWord.ONE)
    val acc = ws.getAccount(block.beneficiary)
    acc.balance = acc.balance.add(new BigInteger("5000000000000000000"))
    ws.setAccount(block.beneficiary, acc)
    
    Assert.assertEquals(ws.stateRoot, block.stateRoot)
  }
}
