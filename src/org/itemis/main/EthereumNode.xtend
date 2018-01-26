/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/

package org.itemis.main

import org.itemis.blockchain.WorldState
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.junit.Assert
import org.itemis.blockchain.BlockchainData
import org.itemis.types.impl.EVMWord
import java.math.BigInteger
import org.itemis.evm.EVMRuntime
import org.itemis.ressources.JsonRPCWrapper
import org.itemis.utils.StaticUtils

final class EthereumNode implements Runnable {
  extension JsonRPCWrapper j = new JsonRPCWrapper
  
  private static final Logger LOGGER = LoggerFactory.getLogger("ExecutionFeedback")
  private static final Logger NODE_LOGGER = LoggerFactory.getLogger("Node")
  
  private static final int BACKUP_STEP = 1000
  private static final int BYZANTIUM_START = 4370000
  
  private static final long AVERAGE_BLOCK_TIME = 15000
  
  private WorldState ws
  
  private final Thread node
  private boolean sleeping = false
  
  new() {
    ws = init()
    node = new Thread(this)
  }
  
  def private update(EVMWord newestBlock) {
    try {
      NODE_LOGGER.trace(String.format("attempting to update to block %s", newestBlock.toBigInteger.toString))
      
      val startBlock = ws.currentBlockNumber.intValue
      
      //iterate over blocks, in a block iterate over transaction, last: apply beneficiary
      for (var b = startBlock; b <= newestBlock.intValue; b++) {
        try {
          var gasReward = EVMWord.ZERO
          
          LOGGER.trace(String.format("starting block %d", b))
          val block = BlockchainData.getBlockByNumber(new EVMWord(b))
          LOGGER.trace(String.format("found %d transactions", block.transactions.length))
          for (var t = 0; t < block.transactions.length; t++) {
            LOGGER.trace(String.format("starting transaction %d", t))
            val transaction = block.transactions.get(t)
            Assert.assertNotNull(transaction)
            LOGGER.debug("\n" + transaction.fields.map[StaticUtils.toHex(it)].join("\n"))
            LOGGER.debug(String.format("transaction hash: %s", transaction.hash))
            val gasUsed = new EVMRuntime(ws).executeTransaction(transaction)
            LOGGER.trace(String.format("adding gas to miner: gas %s gasPrice %s total %s", gasUsed.toBigInteger, transaction.gasPrice.toBigInteger, gasUsed.mul(transaction.gasPrice).toBigInteger))
            gasReward = gasReward.add(gasUsed.mul(transaction.gasPrice))
            ws.incExecutedTransaction
            LOGGER.trace(String.format("done with transaction %d", t))
          }
          if (block.transactions.length == 0) {
            LOGGER.trace("no transactions found")
          }
          
          //add reward
          val beneficiary = ws.getAccount(block.beneficiary)
          val blockReward = new BigInteger(if (b < org.itemis.main.EthereumNode.BYZANTIUM_START) "5000000000000000000" else "3000000000000000000")
          //blockReward + (ommerCount / 32) * blockReward
          val reward = blockReward.add(blockReward.divide(BigInteger.valueOf(32)).multiply(BigInteger.valueOf(block.ommers.length))).add(gasReward.toBigInteger)
          LOGGER.trace(String.format("applying reward of %s wei to %s", reward, block.beneficiary))
          beneficiary.balance = beneficiary.balance.add(reward)
          ws.setAccount(block.beneficiary, beneficiary)
          
          LOGGER.trace(String.format("found %d ommers", block.ommers.length))
          for (var o = 0; o < block.ommers.length; o++) {
            LOGGER.trace(String.format("starting ommer %d", o))
            val ommer = BlockchainData.getOmmerByBlockNumberAndIndex(new EVMWord(b), o)
            val ommerBeneficiary = ws.getAccount(ommer.beneficiary)
            //blockReward + (blockReward / 8)*(ommerBlockNumber - blockNumber) 
            val ommerReward = blockReward.add(blockReward.divide(BigInteger.valueOf(8)).multiply(ommer.number.sub(block.number).toBigInteger))
            LOGGER.trace(String.format("applying ommer reward of %s wei to %s", ommerReward, ommer.beneficiary))
            ommerBeneficiary.balance = ommerBeneficiary.balance.add(ommerReward)
            ws.setAccount(ommer.beneficiary, ommerBeneficiary)
            LOGGER.trace(String.format("done with ommer %d", o))
            LOGGER.debug(String.format("account balance of ommer[%d] %s: %s", o, ommer.beneficiary, ws.getAccount(ommer.beneficiary).balance.toBigInteger))
          }
          
          LOGGER.debug(String.format("account balance of %s: %s", block.beneficiary, ws.getAccount(block.beneficiary).balance.toBigInteger))
          
          LOGGER.trace(String.format("done with block %d", b))
          if (ws.stateRoot.equals(block.stateRoot)) {
            LOGGER.trace(String.format("block successful: %d\n", b))
            ws.incCurrentBlock
          } else {
            LOGGER.debug(String.format("block %d failed: got %s but expected %s\n", b, ws.stateRoot, block.stateRoot))
            LOGGER.warn(String.format("block %d failed: got %s but expected %s", b, ws.stateRoot, block.stateRoot))
            throw new IllegalStateException(String.format("block %d failed", b))
          }
          
          //at every threshold backup state
          if (b % BACKUP_STEP == 0) {
            LOGGER.trace(String.format("backing up %d\n", b))
            ws.copyTo(b.toString)
          } else if (b == newestBlock.intValue) {
            LOGGER.trace(String.format("done with last block %d", b))
            ws.copyTo(b.toString)
          }
        } catch (IllegalStateException e) {
          LOGGER.debug(e.toString)
          throw e
        }
      }
      Assert.assertEquals(ws.stateRoot, BlockchainData.getBlockByNumber(newestBlock).stateRoot)
    } catch (IllegalStateException e) {
      LOGGER.debug(e.toString)
      LOGGER.warn("shutting down")
    }
  }
  
  def private WorldState init() {
    NODE_LOGGER.trace("initializing...")
    
    LOGGER.trace("removing node DB")
    new WorldState("node").delete
    
    val newestBlock = eth_blockNumber
    NODE_LOGGER.trace(String.format("newest Block: %d", newestBlock.intValue))
    LOGGER.trace(String.format("newest Block: %d", newestBlock.intValue))
    var mostRecentBackup = (newestBlock.intValue / BACKUP_STEP) * BACKUP_STEP
    
    //check for newest backup
    
    var WorldState ws = null
    var loadNewestBlock = false
    var loadGenesis = false
    //newest block
    if (!WorldState.exists(newestBlock.intValue.toString)) {
      //every BACKUP_STEP blocks below (starting rounded down to the nearest multiple of BACKUP_STEP)
      while (!WorldState.exists(mostRecentBackup.toString) && mostRecentBackup > 0) {
        LOGGER.trace(String.format("didn't find backup %d", mostRecentBackup))
        mostRecentBackup -= BACKUP_STEP
      }
      
      //if not found, try genesis
      if (mostRecentBackup == 0) {
        if (!WorldState.exists("genesis")) {
          LOGGER.trace("didn't find backup genesis")
          loadGenesis = true
        } else {
          LOGGER.trace("found backup genesis")
          WorldState.copy("genesis", "node")
        }
      } else {
        LOGGER.trace(String.format("found backup %d", mostRecentBackup))
        WorldState.copy(mostRecentBackup.toString, "node")
      }
    } else {
      loadNewestBlock = true
      LOGGER.trace(String.format("found backup %d", newestBlock.intValue))
      WorldState.copy(newestBlock.intValue.toString, "node")
    }
    
    ws = new WorldState("node")
    if (loadGenesis) {
      LOGGER.trace("loading genesis state")
      ws.loadGenesisState(true)

      val size = ws.accountCount
      val root = ws.stateRoot
  
      Assert.assertEquals(size, 8893)
      Assert.assertEquals(root, BlockchainData.getBlockByNumber(EVMWord.ZERO).stateRoot)
      
      LOGGER.trace("backing up to genesis")
      ws.copyTo("genesis")
    }
    
    if (!loadNewestBlock) {
      val startBlock = if (loadGenesis) 1 else (mostRecentBackup + 1)
      LOGGER.trace("verifying...")
      Assert.assertNotNull(ws)
      Assert.assertNotNull(BlockchainData.getBlockByNumber(new EVMWord(startBlock).dec))
      Assert.assertEquals(ws.stateRoot, BlockchainData.getBlockByNumber(new EVMWord(startBlock).dec).stateRoot)
      LOGGER.trace("loaded state is correct\n")
      ws.currentBlock = new EVMWord(startBlock)
    } else {
      LOGGER.trace("verifying...")
      Assert.assertEquals(ws.stateRoot, BlockchainData.getBlockByNumber(newestBlock).stateRoot)
      LOGGER.trace("loaded state is correct\n")
      LOGGER.trace("already done")
    }
    ws
  }
  
  override run() {
    try {
      while (true) {
        NODE_LOGGER.trace("checking for updates...")
  //      val newestBlock = eth_blockNumber
        val newestBlock = new EVMWord(49017) //TODO 
        if (newestBlock.greaterThan(ws.currentBlockNumber)) {
          update(newestBlock)
        } else {
          NODE_LOGGER.trace("no update found")
        }
        ws.shutdown
        sleeping = true
        Thread.sleep(AVERAGE_BLOCK_TIME)
        sleeping = false
        ws = new WorldState("node")
      }
    } catch (InterruptedException e) {
      Thread.currentThread.interrupt
      NODE_LOGGER.info("interrupted, node shutting down")
      ws.shutdown
    }
  }
  
  def synchronized start() {
    if (!node.isAlive) {
      node.start
    } else {
      NODE_LOGGER.warn("node already running")
    }
  }
  
  def synchronized join() {
    node.join
  }
  
  def synchronized interrupt() {
    node.interrupt
    LOGGER.trace("node interrupted")
  }
  
  def synchronized copyWorldState(String destination) {
    if (sleeping) {
      ws.copyTo(destination)
    }
  }
}