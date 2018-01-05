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

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.itemis.utils.db.TwoLevelDBCache
import org.itemis.types.impl.EVMWord
import java.sql.PreparedStatement
import org.apache.commons.lang3.tuple.Triple
import java.sql.ResultSet
import org.itemis.utils.db.DataBaseWrapper.DataBaseID
import org.itemis.types.UnsignedByte
import org.itemis.ressources.JsonRPCWrapper
import org.itemis.types.impl.Hash256
import org.itemis.types.impl.Bloom2048
import org.itemis.types.impl.Address
import org.itemis.types.impl.EthashNonce
import java.math.BigInteger
import org.itemis.utils.ShutdownSequence

abstract class BlockchainData {
  static extension JsonRPCWrapper j = new JsonRPCWrapper

  private final static Logger LOGGER = LoggerFactory.getLogger("Database")

  private final static int MAX_BLOCK_LOOKUP_CACHE_SIZE = 10
  private final static int MAX_BLOCK_CACHE_SIZE = 10
  private final static int MAX_OMMER_LOOKUP_CACHE_SIZE = 10
  private final static int MAX_OMMER_CACHE_SIZE = 10

  private final static int MAX_TRANSACTION_LOOKUP_CACHE_SIZE = 10
  private final static int MAX_TRANSACTION_CACHE_SIZE = 10

  private final static String BLOCK_LOOKUP_TABLE_STR = "blockLookUp (blockNumber BINARY(32) PRIMARY KEY, blockHash BINARY(32))"
  private final static String BLOCK_TABLE_STR = "block (blockHash BINARY(32) PRIMARY KEY, parentHash BINARY(32), ommersHash BINARY(32), beneficiary BINARY(20), stateRoot BINARY(32), transactionsRoot BINARY(32), receiptsRoot BINARY(32), logsBloom BINARY(256), difficulty BINARY(32), number BINARY(32), gasUsed BINARY(32), gasLimit BINARY(32), timestamp BINARY(32), extraData BINARY(32), mixHash BINARY(32), nonce BINARY(32), transactionCount BIGINT, ommerCount BIGINT)"

  private final static String OMMER_LOOKUP_TABLE_STR = "ommerLookUp (blockHash BINARY(32), index INTEGER, ommerHash BINARY(32), PRIMARY KEY (blockHash, index))"
  private final static String OMMER_TABLE_STR = "ommer (blockHash BINARY(32) PRIMARY KEY, parentHash BINARY(32), ommersHash BINARY(32), beneficiary BINARY(20), stateRoot BINARY(32), transactionsRoot BINARY(32), receiptsRoot BINARY(32), logsBloom BINARY(256), difficulty BINARY(32), number BINARY(32), gasUsed BINARY(32), gasLimit BINARY(32), timestamp BINARY(32), extraData BINARY(32), mixHash BINARY(32), nonce BINARY(32))"

  private final static String TRANSACTION_LOOKUP_TABLE_STR = "transactionLookUp (blockNumber BINARY(32), index INTEGER, transactionHash BINARY(32), PRIMARY KEY (blockNumber, index))"
  private final static String TRANSACTION_TABLE_STR = "transaction (transactionHash BINARY(32) PRIMARY KEY, nonce BINARY(32), gasPrice BINARY(32), gasLimit BINARY(32), recipient BINARY(20), value BINARY(32), v TINYINT, r BINARY(32), s BINARY(32), data LONGVARBINARY, sender BINARY(20))"

  private final static String INSERT_BLOCK_LOOKUP_STMT_STR = "INSERT INTO blockLookUp VALUES (?, ?)"
  private final static String SELECT_BLOCK_LOOKUP_STMT_STR = "SELECT * FROM blockLookUp WHERE blockNumber=?"
  private final static String DELETE_BLOCK_LOOKUP_STMT_STR = "DELETE FROM blockLookUp WHERE blockNumber=?"

  private final static String INSERT_BLOCK_STMT_STR = "INSERT INTO block VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
  private final static String SELECT_BLOCK_STMT_STR = "SELECT * FROM block WHERE blockHash=?"
  private final static String DELETE_BLOCK_STMT_STR = "DELETE FROM block WHERE blockHash=?"

  private final static String INSERT_OMMER_LOOKUP_STMT_STR = "INSERT INTO ommerLookUp VALUES (?, ?, ?)"
  private final static String SELECT_OMMER_LOOKUP_STMT_STR = "SELECT * FROM ommerLookUp WHERE blockHash=? AND index=?"
  private final static String DELETE_OMMER_LOOKUP_STMT_STR = "DELETE FROM ommerLookUp WHERE blockHash=? AND index=?"

  private final static String INSERT_OMMER_STMT_STR = "INSERT INTO ommer VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
  private final static String SELECT_OMMER_STMT_STR = "SELECT * FROM ommer WHERE blockHash=?"
  private final static String DELETE_OMMER_STMT_STR = "DELETE FROM ommer WHERE blockHash=?"

  private final static String INSERT_TRANSACTION_LOOKUP_STMT_STR = "INSERT INTO transactionLookUp VALUES (?, ?, ?)"
  private final static String SELECT_TRANSACTION_LOOKUP_STMT_STR = "SELECT * FROM transactionLookUp WHERE blockNumber=? AND index=?"
  private final static String DELETE_TRANSACTION_LOOKUP_STMT_STR = "DELETE FROM transactionLookUp WHERE blockNumber=? AND index=?"

  private final static String INSERT_TRANSACTION_STMT_STR = "INSERT INTO transaction VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
  private final static String SELECT_TRANSACTION_STMT_STR = "SELECT * FROM transaction WHERE transactionHash=?"
  private final static String DELETE_TRANSACTION_STMT_STR = "DELETE FROM transaction WHERE transactionHash=?"

  private final static TwoLevelDBCache<EVMWord, Hash256> blockLookUp = new TwoLevelDBCache<EVMWord, Hash256>(
    MAX_BLOCK_LOOKUP_CACHE_SIZE,
    DataBaseID.CHAINDATA,
    "chain",
    BLOCK_LOOKUP_TABLE_STR,
    INSERT_BLOCK_LOOKUP_STMT_STR,
    [BlockchainData::fillBlockLookUpInsertStatement(it)],
    SELECT_BLOCK_LOOKUP_STMT_STR,
    [BlockchainData::fillBlockLookUpSelectStatement(it)],
    [BlockchainData::readBlockHashFromResultSet(it)],
    DELETE_BLOCK_LOOKUP_STMT_STR,
    [BlockchainData::fillBlockLookUpDeleteStatement(it)]
  )
  private final static TwoLevelDBCache<Hash256, Block> block = new TwoLevelDBCache<Hash256, Block>(
    MAX_BLOCK_CACHE_SIZE,
    DataBaseID.CHAINDATA,
    "chain",
    BLOCK_TABLE_STR,
    INSERT_BLOCK_STMT_STR,
    [BlockchainData::fillBlockInsertStatement(it)],
    SELECT_BLOCK_STMT_STR,
    [BlockchainData::fillBlockSelectStatement(it)],
    [BlockchainData::readBlockFromResultSet(it)],
    DELETE_BLOCK_STMT_STR,
    [BlockchainData::fillBlockDeleteStatement(it)]
  )
  private final static TwoLevelDBCache<Pair<Hash256, Integer>, Hash256> ommerLookUp = new TwoLevelDBCache<Pair<Hash256, Integer>, Hash256>(
    MAX_OMMER_LOOKUP_CACHE_SIZE,
    DataBaseID.CHAINDATA,
    "chain",
    OMMER_LOOKUP_TABLE_STR,
    INSERT_OMMER_LOOKUP_STMT_STR,
    [BlockchainData::fillOmmerLookUpInsertStatement(it)],
    SELECT_OMMER_LOOKUP_STMT_STR,
    [BlockchainData::fillOmmerLookUpSelectStatement(it)],
    [BlockchainData::readOmmerLookUpHashFromResultSet(it)],
    DELETE_OMMER_LOOKUP_STMT_STR,
    [BlockchainData::fillOmmerLookUpDeleteStatement(it)]
  )
  private final static TwoLevelDBCache<Hash256, Block> ommer = new TwoLevelDBCache<Hash256, Block>(
    MAX_OMMER_CACHE_SIZE,
    DataBaseID.CHAINDATA,
    "chain",
    OMMER_TABLE_STR,
    INSERT_OMMER_STMT_STR,
    [BlockchainData::fillOmmerInsertStatement(it)],
    SELECT_OMMER_STMT_STR,
    [BlockchainData::fillBlockSelectStatement(it)],
    [BlockchainData::readOmmerFromResultSet(it)],
    DELETE_OMMER_STMT_STR,
    [BlockchainData::fillBlockDeleteStatement(it)]
  )
  private final static TwoLevelDBCache<Pair<Hash256, Integer>, Hash256> transactionLookUp = new TwoLevelDBCache<Pair<Hash256, Integer>, Hash256>(
    MAX_TRANSACTION_LOOKUP_CACHE_SIZE,
    DataBaseID.CHAINDATA,
    "chain",
    TRANSACTION_LOOKUP_TABLE_STR,
    INSERT_TRANSACTION_LOOKUP_STMT_STR,
    [BlockchainData::fillTransactionLookUpInsertStatement(it)],
    SELECT_TRANSACTION_LOOKUP_STMT_STR,
    [BlockchainData::fillTransactionLookUpSelectStatement(it)],
    [BlockchainData::readTransactionHashFromResultSet(it)],
    DELETE_TRANSACTION_LOOKUP_STMT_STR,
    [BlockchainData::fillTransactionLookUpDeleteStatement(it)]
  )
  private final static TwoLevelDBCache<Hash256, Transaction> transaction = new TwoLevelDBCache<Hash256, Transaction>(
    MAX_TRANSACTION_CACHE_SIZE,
    DataBaseID.CHAINDATA,
    "chain",
    TRANSACTION_TABLE_STR,
    INSERT_TRANSACTION_STMT_STR,
    [BlockchainData::fillTransactionInsertStatement(it)],
    SELECT_TRANSACTION_STMT_STR,
    [BlockchainData::fillTransactionSelectStatement(it)],
    [BlockchainData::readTransactionFromResultSet(it)],
    DELETE_TRANSACTION_STMT_STR,
    [BlockchainData::fillTransactionDeleteStatement(it)]
  )
  
  private final static boolean shutdownHookAdded = {
    ShutdownSequence.registerShutdownClass(BlockchainData)
    true
  }
  
  // BlockLookUp
  def private static PreparedStatement fillBlockLookUpInsertStatement(
    Triple<EVMWord, Hash256, PreparedStatement> triple) {
    val blockNumber = triple.left
    val blockHash = triple.middle
    val stmt = triple.right

    stmt.setBytes(1, blockNumber.toByteArray)
    stmt.setBytes(2, blockHash.toByteArray)

    stmt
  }

  def private static PreparedStatement fillBlockLookUpSelectStatement(Pair<EVMWord, PreparedStatement> pair) {
    val blockNumber = pair.key
    val stmt = pair.value

    stmt.setBytes(1, blockNumber.toByteArray)

    stmt
  }

  def private static PreparedStatement fillBlockLookUpDeleteStatement(Pair<EVMWord, PreparedStatement> pair) {
    val blockNumber = pair.key
    val stmt = pair.value

    stmt.setBytes(1, blockNumber.toByteArray)

    stmt
  }

  def private static Hash256 readBlockHashFromResultSet(Pair<ResultSet, EVMWord> pair) {
    val resultSet = pair.key

    try {
      resultSet.next

      new Hash256(resultSet.getBytes("blockHash"))
    } catch(Exception e) {
      if (!e.toString.contains("invalid cursor state")) {
        LOGGER.debug(e.message)
      }
      null
    }
  }

  // Block
  def private static PreparedStatement fillBlockInsertStatement(Triple<Hash256, Block, PreparedStatement> triple) {
    val blockHash = triple.left
    val block = triple.middle
    val stmt = triple.right

    stmt.setBytes(1, blockHash.toByteArray)
    stmt.setBytes(2, block.parentHash.toByteArray)
    stmt.setBytes(3, block.ommersHash.toByteArray)
    stmt.setBytes(4, block.beneficiary.toByteArray)
    stmt.setBytes(5, block.stateRoot.toByteArray)
    stmt.setBytes(6, block.transactionsRoot.toByteArray)
    stmt.setBytes(7, block.receiptsRoot.toByteArray)
    stmt.setBytes(8, block.logsBloom.toByteArray)
    stmt.setBytes(9, block.difficulty.toByteArray)
    stmt.setBytes(10, block.number.toByteArray)
    stmt.setBytes(11, block.gasUsed.toByteArray)
    stmt.setBytes(12, block.gasLimit.toByteArray)
    stmt.setBytes(13, block.timestamp.toByteArray)
    stmt.setBytes(14, block.extraData)
    stmt.setBytes(15, block.mixHash.toByteArray)
    stmt.setBytes(16, block.nonce.toByteArray)
    stmt.setLong(17, block.transactions.length)
    stmt.setLong(18, block.ommers.length)

    stmt
  }

  def private static PreparedStatement fillBlockSelectStatement(Pair<Hash256, PreparedStatement> pair) {
    val blockHash = pair.key
    val stmt = pair.value

    stmt.setBytes(1, blockHash.toByteArray)

    stmt
  }

  def private static PreparedStatement fillBlockDeleteStatement(Pair<Hash256, PreparedStatement> pair) {
    val blockHash = pair.key
    val stmt = pair.value

    stmt.setBytes(1, blockHash.toByteArray)

    stmt
  }

  def private static Block readBlockFromResultSet(Pair<ResultSet, Hash256> pair) {
    val resultSet = pair.key
    val hash = pair.value

    try {
      resultSet.next

      val resultBlock = new Block()

      resultBlock.parentHash = new Hash256(resultSet.getBytes("parentHash"))
      resultBlock.ommersHash = new Hash256(resultSet.getBytes("ommersHash"))
      resultBlock.beneficiary = new Address(resultSet.getBytes("beneficiary"))
      resultBlock.stateRoot = new Hash256(resultSet.getBytes("stateRoot"))
      resultBlock.transactionsRoot = new Hash256(resultSet.getBytes("transactionsRoot"))
      resultBlock.receiptsRoot = new Hash256(resultSet.getBytes("receiptsRoot"))
      resultBlock.logsBloom = new Bloom2048(resultSet.getBytes("logsBloom"))
      resultBlock.difficulty = new EVMWord(resultSet.getBytes("difficulty"))
      resultBlock.number = new EVMWord(resultSet.getBytes("number"))
      resultBlock.gasUsed = new EVMWord(resultSet.getBytes("gasUsed"))
      resultBlock.gasLimit = new EVMWord(resultSet.getBytes("gasLimit"))
      resultBlock.timestamp = new EVMWord(resultSet.getBytes("timestamp"))
      resultBlock.extraData = resultSet.getBytes("extraData")
      resultBlock.mixHash = new Hash256(resultSet.getBytes("mixHash"))
      resultBlock.nonce = new EthashNonce(resultSet.getBytes("nonce"))
      for (var t = 0; t < resultSet.getLong("transactionCount"); t++) {
        resultBlock.transactions.add(getTransactionByBlockHashAndIndex(hash, t))
      }
      for (var o = 0; o < resultSet.getLong("ommerCount"); o++) {
        resultBlock.ommers.add(getOmmerByBlockHashAndIndex(hash, o).hash)
      }

      resultBlock
    } catch(Exception e) {
      if (!e.toString.contains("invalid cursor state")) {
        LOGGER.debug(e.message)
      }
      null
    }
  }

  // OmmerLookUp
  def private static PreparedStatement fillOmmerLookUpInsertStatement(
    Triple<Pair<Hash256, Integer>, Hash256, PreparedStatement> triple) {
    val blockHash = triple.left.key
    val index = triple.left.value
    val ommerHash = triple.middle
    val stmt = triple.right

    stmt.setBytes(1, blockHash.toByteArray)
    stmt.setInt(2, index)
    stmt.setBytes(3, ommerHash.toByteArray)

    stmt
  }

  def private static PreparedStatement fillOmmerLookUpSelectStatement(
    Pair<Pair<Hash256, Integer>, PreparedStatement> pair) {
    val blockHash = pair.key.key
    val index = pair.key.value
    val stmt = pair.value

    stmt.setBytes(1, blockHash.toByteArray)
    stmt.setInt(2, index)

    stmt
  }

  def private static PreparedStatement fillOmmerLookUpDeleteStatement(
    Pair<Pair<Hash256, Integer>, PreparedStatement> pair) {
    val blockHash = pair.key.key
    val index = pair.key.value
    val stmt = pair.value

    stmt.setBytes(1, blockHash.toByteArray)
    stmt.setInt(2, index)

    stmt
  }

  def private static Hash256 readOmmerLookUpHashFromResultSet(Pair<ResultSet, Pair<Hash256, Integer>> pair) {
    val resultSet = pair.key

    try {
      resultSet.next

      new Hash256(resultSet.getBytes("ommerHash"))
    } catch(Exception e) {
      if (!e.toString.contains("invalid cursor state")) {
        LOGGER.debug(e.message)
      }
      null
    }
  }

  // Ommer
  def private static PreparedStatement fillOmmerInsertStatement(Triple<Hash256, Block, PreparedStatement> triple) {
    val blockHash = triple.left
    val block = triple.middle
    val stmt = triple.right

    stmt.setBytes(1, blockHash.toByteArray)
    stmt.setBytes(2, block.parentHash.toByteArray)
    stmt.setBytes(3, block.ommersHash.toByteArray)
    stmt.setBytes(4, block.beneficiary.toByteArray)
    stmt.setBytes(5, block.stateRoot.toByteArray)
    stmt.setBytes(6, block.transactionsRoot.toByteArray)
    stmt.setBytes(7, block.receiptsRoot.toByteArray)
    stmt.setBytes(8, block.logsBloom.toByteArray)
    stmt.setBytes(9, block.difficulty.toByteArray)
    stmt.setBytes(10, block.number.toByteArray)
    stmt.setBytes(11, block.gasUsed.toByteArray)
    stmt.setBytes(12, block.gasLimit.toByteArray)
    stmt.setBytes(13, block.timestamp.toByteArray)
    stmt.setBytes(14, block.extraData)
    stmt.setBytes(15, block.mixHash.toByteArray)
    stmt.setBytes(16, block.nonce.toByteArray)

    stmt
  }

  def private static Block readOmmerFromResultSet(Pair<ResultSet, Hash256> pair) {
    val resultSet = pair.key

    try {
      resultSet.next

      val resultBlock = new Block()

      resultBlock.parentHash = new Hash256(resultSet.getBytes("parentHash"))
      resultBlock.ommersHash = new Hash256(resultSet.getBytes("ommersHash"))
      resultBlock.beneficiary = new Address(resultSet.getBytes("beneficiary"))
      resultBlock.stateRoot = new Hash256(resultSet.getBytes("stateRoot"))
      resultBlock.transactionsRoot = new Hash256(resultSet.getBytes("transactionsRoot"))
      resultBlock.receiptsRoot = new Hash256(resultSet.getBytes("receiptsRoot"))
      resultBlock.logsBloom = new Bloom2048(resultSet.getBytes("logsBloom"))
      resultBlock.difficulty = new EVMWord(resultSet.getBytes("difficulty"))
      resultBlock.number = new EVMWord(resultSet.getBytes("number"))
      resultBlock.gasUsed = new EVMWord(resultSet.getBytes("gasUsed"))
      resultBlock.gasLimit = new EVMWord(resultSet.getBytes("gasLimit"))
      resultBlock.timestamp = new EVMWord(resultSet.getBytes("timestamp"))
      resultBlock.extraData = resultSet.getBytes("extraData")
      resultBlock.mixHash = new Hash256(resultSet.getBytes("mixHash"))
      resultBlock.nonce = new EthashNonce(resultSet.getBytes("nonce"))

      resultBlock
    } catch(Exception e) {
      if (!e.toString.contains("invalid cursor state")) {
        LOGGER.debug(e.message)
      }
      null
    }
  }

  // TransactionLookUp
  def private static PreparedStatement fillTransactionLookUpInsertStatement(
    Triple<Pair<Hash256, Integer>, Hash256, PreparedStatement> triple) {
    val blockHash = triple.left.key
    val index = triple.left.value
    val transactionHash = triple.middle
    val stmt = triple.right

    stmt.setBytes(1, blockHash.toByteArray)
    stmt.setInt(2, index)
    stmt.setBytes(3, transactionHash.toByteArray)

    stmt
  }

  def private static PreparedStatement fillTransactionLookUpSelectStatement(
    Pair<Pair<Hash256, Integer>, PreparedStatement> pair) {
    val blockHash = pair.key.key
    val index = pair.key.value
    val stmt = pair.value

    stmt.setBytes(1, blockHash.toByteArray)
    stmt.setInt(2, index)

    stmt
  }

  def private static PreparedStatement fillTransactionLookUpDeleteStatement(
    Pair<Pair<Hash256, Integer>, PreparedStatement> pair) {
    val blockHash = pair.key.key
    val index = pair.key.value
    val stmt = pair.value

    stmt.setBytes(1, blockHash.toByteArray)
    stmt.setInt(2, index)

    stmt
  }

  def private static Hash256 readTransactionHashFromResultSet(Pair<ResultSet, Pair<Hash256, Integer>> pair) {
    val resultSet = pair.key

    try {
      resultSet.next

      new Hash256(resultSet.getBytes("transactionHash"))
    } catch(Exception e) {
      if (!e.toString.contains("invalid cursor state")) {
        LOGGER.debug(e.message)
      }
      null
    }
  }

  // Transaction
  def private static PreparedStatement fillTransactionInsertStatement(Triple<Hash256, Transaction, PreparedStatement> triple) {
    try {
      val transactionHash = triple.left
      val transaction = triple.middle
      val stmt = triple.right
  
      stmt.setBytes(1, transactionHash.toByteArray)
      stmt.setBytes(2, transaction.nonce.toByteArray)
      stmt.setBytes(3, transaction.gasPrice.toByteArray)
      stmt.setBytes(4, transaction.gasLimit.toByteArray)
      stmt.setBytes(5, if(transaction.to !== null) transaction.to.toByteArray)
      stmt.setBytes(6, transaction.value.toByteArray)
      stmt.setInt(7, transaction.v.intValue)
      stmt.setBytes(8, transaction.r.toByteArray)
      stmt.setBytes(9, transaction.s.toByteArray)
      stmt.setBytes(10, transaction.data.map[byteValue])
      stmt.setBytes(11, transaction.sender.toByteArray)
  
      stmt
    } catch (Exception e) {
      throw e
    }
  }

  def private static PreparedStatement fillTransactionSelectStatement(Pair<Hash256, PreparedStatement> pair) {
    val transactionHash = pair.key
    val stmt = pair.value

    stmt.setBytes(1, transactionHash.toByteArray)

    stmt
  }

  def private static PreparedStatement fillTransactionDeleteStatement(Pair<Hash256, PreparedStatement> pair) {
    val transactionHash = pair.key
    val stmt = pair.value

    stmt.setBytes(1, transactionHash.toByteArray)

    stmt
  }

  def private static Transaction readTransactionFromResultSet(Pair<ResultSet, Hash256> pair) {
    val resultSet = pair.key

    try {
      resultSet.next

      val resultTransaction = new Transaction()

      resultTransaction.nonce = new EVMWord(resultSet.getBytes("nonce"))
      resultTransaction.gasPrice = new EVMWord(resultSet.getBytes("gasPrice"))
      resultTransaction.gasLimit = new EVMWord(resultSet.getBytes("gasLimit"))
      val _to = resultSet.getBytes("recipient")
      resultTransaction.to = if(_to !== null) new Address(_to)
      resultTransaction.value = new EVMWord(resultSet.getBytes("value"))
      resultTransaction.v = new UnsignedByte(resultSet.getInt("v"))
      resultTransaction.r = new BigInteger(resultSet.getBytes("r"))
      resultTransaction.s = new BigInteger(resultSet.getBytes("s"))
      resultTransaction.data = resultSet.getBytes("data").map[new UnsignedByte(it)]
      resultTransaction.sender = new Address(resultSet.getBytes("sender"))

      resultTransaction
    } catch(Exception e) {
      if (!e.toString.contains("invalid cursor state")) {
        LOGGER.debug(e.message)
      }
      null
    }
  }

  def private static void persistOmmer(Hash256 blockHash, Integer index) {
    val ommerBlock = eth_getUncleByBlockHashAndIndex(blockHash, new EVMWord(index))
    persistOmmer(ommerBlock, ommerBlock.hash, blockHash, index)
  }

  def private static void persistOmmer(Block b, Hash256 ommerHash, Hash256 blockHash, Integer index) {
    ommerLookUp.put(Pair.of(blockHash, index), ommerHash)
    if(ommer.lookUp(ommerHash) === null) {
      ommer.put(ommerHash, b)
    }
  }

  def private static void persistBlock(Block b, Hash256 blockHash) {
    block.put(blockHash, b)
    blockLookUp.put(b.number, blockHash)
    for (var i = 0; i < b.ommers.size; i++) {
      if(ommerLookUp.lookUp(Pair.of(blockHash, i)) === null) {
        persistOmmer(blockHash, i)
      }
    }
    for (var i = 0; i < b.transactions.size; i++) {
      val transactionHash = b.transactions.get(i).hash
      transactionLookUp.put(Pair.of(blockHash, i), transactionHash)
      transaction.put(transactionHash, b.transactions.get(i))
    }
  }

  def private static void persistTransaction(Transaction t, Hash256 transactionHash, Hash256 blockHash, Integer index) {
    transactionLookUp.put(Pair.of(blockHash, index), transactionHash)
    if(transaction.lookUp(transactionHash) === null) {
      transaction.put(transactionHash, t)
    }
  }

  def static Block getBlockByHash(Hash256 blockHash) {
    var resultBlock = block.lookUp(blockHash)
    if(resultBlock === null) {
      resultBlock = eth_getBlockByHash(blockHash)
      persistBlock(resultBlock, blockHash)
    }

    resultBlock
  }

  def static Hash256 getBlockHashByNumber(EVMWord blockNumber) {
    blockLookUp.lookUp(blockNumber) ?: eth_getBlockByNumber_hash(blockNumber, null)
  }

  def static Block getBlockByNumber(EVMWord blockNumber) {
    getBlockByHash(getBlockHashByNumber(blockNumber))
  }

  def static Block getOmmerByBlockHashAndIndex(Hash256 blockHash, Integer index) {
    var resultHash = ommerLookUp.lookUp(Pair.of(blockHash, index))
    var resultBlock = ommer.lookUp(resultHash)
    if(resultBlock === null) {
      resultBlock = eth_getUncleByBlockHashAndIndex(blockHash, new EVMWord(index))
      persistOmmer(resultBlock, resultBlock.hash, blockHash, index)
    }

    resultBlock
  }

  def static Block getOmmerByBlockNumberAndIndex(EVMWord blockNumber, Integer index) {
    getOmmerByBlockHashAndIndex(getBlockHashByNumber(blockNumber), index)
  }

  def static Transaction getTransactionByHash(Hash256 transactionHash) {
    var resultTransaction = transaction.lookUp(transactionHash)
    if(resultTransaction === null) {
      resultTransaction = eth_getTransactionByHash(transactionHash)
      if(transaction.lookUp(transactionHash) === null) {
        transaction.put(transactionHash, resultTransaction)
      }
    }

    resultTransaction
  }

  def static Transaction getTransactionByBlockHashAndIndex(Hash256 blockHash, Integer index) {
    var transactionHash = transactionLookUp.lookUp(Pair.of(blockHash, index))
    var resultTransaction = transaction.lookUp(transactionHash)
    if(resultTransaction === null) {
      resultTransaction = eth_getTransactionByBlockHashAndIndex(blockHash, new EVMWord(index))
      persistTransaction(resultTransaction, transactionHash, blockHash, index)
    }

    resultTransaction
  }
  
  def static void shutdown() {
    if (shutdownHookAdded) {
      flush
    }
  }

  def static void flush() {
    blockLookUp.flush
    block.flush
    ommerLookUp.flush
    ommer.flush
    transactionLookUp.flush
    transaction.flush
  }
}
