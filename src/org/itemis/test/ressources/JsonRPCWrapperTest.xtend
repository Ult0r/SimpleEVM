package org.itemis.test.ressources

import org.junit.Test
import org.itemis.evm.types.EVMWord
import org.itemis.ressources.JsonRPCWrapper
import org.junit.Assert
import org.itemis.evm.utils.Utils

class JsonRPCWrapperTest {
  extension JsonRPCWrapper j = new JsonRPCWrapper
  extension Utils u = new Utils
  
  // HELPER
  @Test
  def void testIdentifyBlock() {
    val EVMWord zero = new EVMWord(0)
    
    Assert.assertEquals(identifyBlock(zero, null), zero.toTrimmedString)
    Assert.assertEquals(identifyBlock(zero, "earliest"), zero.toTrimmedString)
    Assert.assertEquals(identifyBlock(null, "earliest"), "earliest")
  }
  
  @Test(expected = IllegalArgumentException)
  def void testIdentifyBlockInvalidTag() {
    identifyBlock(null, "This is not a valid block tag")
  }
  
  @Test(expected = IllegalArgumentException)
  def void testIdentifyBlockBothNull() {
    identifyBlock(null, null)
  }
  
  // METHODS
  @Test
  def void testWeb3_clientVersion() {
    val String clientVersion = web3_clientVersion
    Assert.assertTrue(clientVersion.startsWith("Geth"))
  }
  
  @Test
  def void testWeb3_sha3() {
    Assert.assertEquals(web3_sha3(""), keccak256("".bytes))
  }
  
  @Test
  def void testNet_version() {
    Assert.assertEquals(net_version, "1")
  }
  
  @Test
  def void testNet_listening() {
    Assert.assertTrue(net_listening)
  }
  
  @Test
  def void testNet_peerCount() {
    Assert.assertNotEquals(net_peerCount, 0)
  }
  
  @Test
  def void testEth_protocolVersion() {
    Assert.assertFalse(EVMWord.fromString(eth_protocolVersion).isZero)
  }
  
  @Test
  def void testEth_syncing() {
    val sync = eth_syncing
    Assert.assertNotNull(sync)
    
    try {
      Assert.assertFalse(sync.asBoolean)
    } catch (Exception e) {
      Assert.assertFalse(eth_syncing_startingBlock.get.isZero)
      Assert.assertFalse(eth_syncing_currentBlock.get.isZero)
      Assert.assertFalse(eth_syncing_highestBlock.get.isZero)
    }
  }
  
  @Test(expected = UnsupportedOperationException)
  def void testEth_coinbase() {
    eth_coinbase
  }
  
  @Test
  def void testEth_mining() {
    Assert.assertFalse(eth_mining)
  }
  
  @Test
  def void testEth_hashrate() {
    Assert.assertTrue(eth_hashrate.isZero)
  }
  
  @Test
  def void testEth_gasPrice() {
    Assert.assertFalse(eth_gasPrice.isZero)
  }
  
  @Test
  def void testEth_accounts() {
    Assert.assertEquals(eth_accounts.length, 0)
  }
  
  @Test
  def void testEth_blockNumber() {
    Assert.assertFalse(eth_blockNumber.isZero)
  }
  
  @Test
  def void testEth_getBalance() {
    Assert.assertTrue(eth_getBalance(
      EVMWord.fromString("0xb19264f813465b8e6147ed011c7761c71054e91f"),
      new EVMWord(4079009),
      null
    ).isZero)
    
    Assert.assertFalse(eth_getBalance(
      EVMWord.fromString("0xb19264f813465b8e6147ed011c7761c71054e91f"),
      new EVMWord(4079011),
      null
    ).isZero)
    
    Assert.assertEquals(eth_getBalance(
      EVMWord.fromString("0xb19264f813465b8e6147ed011c7761c71054e91f"),
      new EVMWord(4079011),
      null
    ).toIntString, "187036535988387584")
    
    Assert.assertEquals(eth_getBalance(
      EVMWord.fromString("0xb19264f813465b8e6147ed011c7761c71054e91f"),
      new EVMWord(4149495),
      null
    ).toIntString, "237420299500067120")
  }
}
