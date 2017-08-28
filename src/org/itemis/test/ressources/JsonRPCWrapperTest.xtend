/*******************************************************************************
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
* 
* Contributors:
* Lars Reimers for itemis AG
*******************************************************************************/
package org.itemis.test.ressources

import org.junit.Test
import org.itemis.types.EVMWord
import org.itemis.ressources.JsonRPCWrapper
import org.junit.Assert
import org.itemis.utils.Utils
import org.itemis.blockchain.Block
import java.util.logging.Logger
import org.junit.BeforeClass
import org.junit.AfterClass
import org.itemis.utils.logging.LoggerController

class JsonRPCWrapperTest {
  extension JsonRPCWrapper j = new JsonRPCWrapper
  extension Utils u = new Utils
  
  @BeforeClass
  def static void initLogger() {
    val Logger logger = LoggerController.createLogger(JsonRPCWrapperTest)
    LoggerController.addLogger(logger)
  }
  
  @AfterClass
  def static void removeLogger() {
    LoggerController.removeLogger()
  }
  
  // HELPER
  @Test
  def void testIdentifyBlock() {
    val EVMWord zero = new EVMWord(0)

    Assert.assertEquals(identifyBlock(zero, null), zero.toTrimmedString)
    Assert.assertEquals(identifyBlock(zero, "earliest"), zero.toTrimmedString)
    Assert.assertEquals(identifyBlock(null, "earliest"), "earliest")
  }

  @Test(expected=IllegalArgumentException)
  def void testIdentifyBlockInvalidTag() {
    identifyBlock(null, "This is not a valid block tag")
  }

  @Test(expected=IllegalArgumentException)
  def void testIdentifyBlockBothNull() {
    identifyBlock(null, null)
  }

  // METHODS
  @Test
  def void testWeb3_clientVersion() {
    val String clientVersion = web3_clientVersion
    Assert.assertTrue(clientVersion.length > 0)
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
    } catch(Exception e) {
      val startingBlock = eth_syncing_startingBlock
      if (startingBlock.present) {
        Assert.assertFalse(startingBlock.get.isZero)
      }
      
      val currentBlock = eth_syncing_currentBlock
      if (currentBlock.present) {
        Assert.assertFalse(currentBlock.get.isZero)
      }
      
      val highestBlock = eth_syncing_highestBlock
      if (highestBlock.present) {
        Assert.assertFalse(highestBlock.get.isZero)
      }
    }
  }

  @Test(expected=UnsupportedOperationException)
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

  @Test
  def void testEth_getStorageAt() {
    val EVMWord address = EVMWord.fromString("0xe9e7684b674679599b66c3b1c65826ecc9b4d302")
    val EVMWord offset = new EVMWord(0)
    val EVMWord block = new EVMWord(4000000)
    
    val EVMWord result = EVMWord.fromString("0x000001f568875f378bf6d170b790967fe429c81a")
    
    Assert.assertEquals(eth_getStorageAt(address, offset, block, null), result)
  }
  
  @Test
  def void testEth_getTransactionCount() {
    val EVMWord address = EVMWord.fromString("0x52bc44d5378309EE2abF1539BF71dE1b7d7bE3b5")
    val EVMWord block = new EVMWord(4000000)
    
    val EVMWord result = new EVMWord(2333167)
    
    Assert.assertEquals(eth_getTransactionCount(address, block, null), result)
  }
  
  @Test
  def void testEth_getBlockTransactionCountByHash() {
    val EVMWord blockhash = EVMWord.fromString("0xb8a3f7f5cfc1748f91a684f20fe89031202cbadcd15078c49b85ec2a57f43853")
    
    Assert.assertEquals(eth_getBlockTransactionCountByHash(blockhash).toUnsignedInt, 69)
  }
  
  @Test
  def void testEth_getBlockTransactionCountByNumber() {
    val EVMWord blockNumber = new EVMWord(4000000)
    
    Assert.assertEquals(eth_getBlockTransactionCountByNumber(blockNumber, null).toUnsignedInt, 69)
  }
  
  @Test
  def void testEth_getUncleCountByBlockHash() {
    val EVMWord blockhash = EVMWord.fromString("0x7a0736de3a3cdcaec721ebb7735af79dd9dc0c8b99ddb0ffd4fa793d770499e3")
    
    Assert.assertEquals(eth_getUncleCountByBlockHash(blockhash).toUnsignedInt, 1)
  }
  
  @Test
  def void testEth_getUncleCountByBlockNumber() {
    val EVMWord blockNumber = new EVMWord(4000014)
    
    Assert.assertEquals(eth_getUncleCountByBlockNumber(blockNumber, null).toUnsignedInt, 1)
  }
  
  @Test
  def void testEth_getCode() {
    val EVMWord address = EVMWord.fromString("0xa68722974c163a0D26983c50891112e7A4e96c99")
    
    Assert.assertEquals(eth_getCode(address, null, "latest").length, 1106)
  }
  
  @Test(expected=UnsupportedOperationException)
  def void testEth_sign() {
    eth_sign(new EVMWord(0), newArrayOfSize(0))
  }
  
  @Test(expected=UnsupportedOperationException)
  def void testEth_sendTransaction() {
    eth_sendTransaction(new EVMWord(0), new EVMWord(0), new EVMWord(0), new EVMWord(0), new EVMWord(0), newArrayOfSize(0))
  }
  
  @Test(expected=UnsupportedOperationException)
  def void testEth_sendRawTransaction() {
    eth_sendRawTransaction(newArrayOfSize(0))
  }
  
  @Test
  def void testEth_call() {
    Assert.assertEquals(eth_call(
      EVMWord.fromString("0xb794f5ea0ba39494ce839613fffba74279579268"),
      EVMWord.fromString("0xe853c56864a2ebe4576a807d26fdc4a0ada51919"),
      EVMWord.fromString("0xffffff"),
      EVMWord.fromString("0xffffff"),
      EVMWord.fromString("0xffffffffffffffffffff"),
      newArrayOfSize(0),
      null,
      "latest"
    ).length, 0)
  }
  
  @Test
  def void testEth_estimateGas() {
    Assert.assertFalse(eth_estimateGas(
      EVMWord.fromString("0xb794f5ea0ba39494ce839613fffba74279579268"),
      EVMWord.fromString("0xe853c56864a2ebe4576a807d26fdc4a0ada51919"),
      EVMWord.fromString("0xffffff"),
      EVMWord.fromString("0xffffff"),
      EVMWord.fromString("0xffffffffffffffffffff"),
      newArrayOfSize(0)
    ).isZero)
  }
  
  @Test
  def void testEth_getBlockByHash() {
    val EVMWord blockHash = EVMWord.fromString("0xb8a3f7f5cfc1748f91a684f20fe89031202cbadcd15078c49b85ec2a57f43853")
    val Block result = eth_getBlockByHash(blockHash)
    val EVMWord parentHash = EVMWord.fromString("0x9b3c1d182975fdaa5797879cbc45d6b00a84fb3b13980a107645b2491bcca899")
    
    Assert.assertEquals(result.parentHash, parentHash)    
  }
  
  @Test
  def void testEth_getBlockByHash_totalDifficulty() {
    val EVMWord blockHash = EVMWord.fromString("0xb8a3f7f5cfc1748f91a684f20fe89031202cbadcd15078c49b85ec2a57f43853")
    val EVMWord totalDifficulty = EVMWord.fromString("0x196d077461e5dbab12")
    
    Assert.assertEquals(eth_getBlockByHash_totalDifficulty(blockHash), totalDifficulty)    
  }
  
  @Test
  def void testEth_getBlockByHash_size() {
    val EVMWord blockHash = EVMWord.fromString("0xb8a3f7f5cfc1748f91a684f20fe89031202cbadcd15078c49b85ec2a57f43853")
    val EVMWord size = new EVMWord(16263)
    
    Assert.assertEquals(eth_getBlockByHash_size(blockHash), size)    
  }
  
  @Test
  def void testEth_getBlockByHash_transactionHashes() {
    val EVMWord blockHash = EVMWord.fromString("0xb8a3f7f5cfc1748f91a684f20fe89031202cbadcd15078c49b85ec2a57f43853")
    
    Assert.assertEquals(eth_getBlockByHash_transactionHashes(blockHash).length, 69)    
  }
  
  @Test
  def void testEth_getBlockByNumber() {
    val EVMWord blockNumber = new EVMWord(4000000)
    val EVMWord parentHash = EVMWord.fromString("0x9b3c1d182975fdaa5797879cbc45d6b00a84fb3b13980a107645b2491bcca899")
    
    Assert.assertEquals(eth_getBlockByNumber(blockNumber, null).parentHash, parentHash)
  }
  
  @Test
  def void testEth_getBlockByNumber_hash() {
    val EVMWord blockNumber = new EVMWord(4000000)
    val EVMWord blockHash = EVMWord.fromString("0xb8a3f7f5cfc1748f91a684f20fe89031202cbadcd15078c49b85ec2a57f43853")
    
    Assert.assertEquals(eth_getBlockByNumber_hash(blockNumber, null), blockHash)    
  }
  
  @Test
  def void testEth_getBlockByNumber_totalDifficulty() {
    val EVMWord blockNumber = new EVMWord(4000000)
    val EVMWord totalDifficulty = EVMWord.fromString("0x196d077461e5dbab12")
    
    Assert.assertEquals(eth_getBlockByNumber_totalDifficulty(blockNumber, null), totalDifficulty)    
  }
  
  @Test
  def void testEth_getBlockByNumber_size() {
    val EVMWord blockNumber = new EVMWord(4000000)
    val EVMWord size = new EVMWord(16263)
    
    Assert.assertEquals(eth_getBlockByNumber_size(blockNumber, null), size)    
  }
  
  @Test
  def void testEth_getBlockByNumber_transactionHashes() {
    val EVMWord blockNumber = new EVMWord(4000000)
    
    Assert.assertEquals(eth_getBlockByNumber_transactionHashes(blockNumber, null).length, 69)    
  }
  
  @Test
  def void testEth_getTransactionByHash() {
    val EVMWord transactionHash = EVMWord.fromString("0x98afba7bfde015e36a84eb5a9540c79952ddf4176df0a87bea2591a2063cf398")
    
    Assert.assertEquals(eth_getTransactionByHash(transactionHash).nonce, new EVMWord(2537750))
  }
  
  @Test
  def void testEth_getTransactionByBlockHashAndIndex() {
    val EVMWord blockHash = EVMWord.fromString("0xb8a3f7f5cfc1748f91a684f20fe89031202cbadcd15078c49b85ec2a57f43853")
    val EVMWord index = new EVMWord(0)
    
    Assert.assertEquals(eth_getTransactionByBlockHashAndIndex(blockHash, index).nonce, new EVMWord(5))
  }
  
  @Test
  def void testEth_getTransactionByBlockNumberAndIndex() {
    val EVMWord blockNumber = new EVMWord(4000000)
    val EVMWord index = new EVMWord(0)    
    
    Assert.assertEquals(eth_getTransactionByBlockNumberAndIndex(blockNumber, null, index).nonce, new EVMWord(5))
  }
  
  @Test
  def void testEth_getTransactionReceipt() {
    val EVMWord transactionHash = EVMWord.fromString("0x98afba7bfde015e36a84eb5a9540c79952ddf4176df0a87bea2591a2063cf398")
    
    Assert.assertEquals(eth_getTransactionReceipt(transactionHash).blockNumber, new EVMWord(4079010))
  }
  
  @Test
  def void testEth_getUncleByBlockHashAndIndex() {
    val EVMWord blockHash = EVMWord.fromString("0x7a0736de3a3cdcaec721ebb7735af79dd9dc0c8b99ddb0ffd4fa793d770499e3")
    val EVMWord index = new EVMWord(0)
    val EVMWord parentHash = EVMWord.fromString("0x5dbeb17d3c0d0b21167254259274022d8ead55a43453c8492f7568ec9e1b7c16")
    
    Assert.assertEquals(eth_getUncleByBlockHashAndIndex(blockHash, index).parentHash, parentHash)
  }
  
  @Test
  def void testEth_getUncleByBlockNumberAndIndex() {
    val EVMWord blockNumber = new EVMWord(4000014)
    val EVMWord index = new EVMWord(0)    
    val EVMWord parentHash = EVMWord.fromString("0x5dbeb17d3c0d0b21167254259274022d8ead55a43453c8492f7568ec9e1b7c16")
    
    Assert.assertEquals(eth_getUncleByBlockNumberAndIndex(blockNumber, null, index).parentHash, parentHash)
  }
}





















