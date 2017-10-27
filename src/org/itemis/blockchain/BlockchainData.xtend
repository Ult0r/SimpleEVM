package org.itemis.blockchain

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.itemis.utils.db.TwoLevelDBCache
import org.itemis.types.EVMWord
import java.sql.PreparedStatement
import org.apache.commons.lang3.tuple.Triple
import java.sql.ResultSet
import org.itemis.utils.db.DataBaseWrapper.DataBaseID
import org.itemis.types.Int2048
import org.itemis.types.UnsignedByte
import org.itemis.ressources.JsonRPCWrapper

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
  private final static String BLOCK_TABLE_STR = "block (blockHash BINARY(32) PRIMARY KEY, parentHash BINARY(32), ommersHash BINARY(32), beneficiary BINARY(32), stateRoot BINARY(32), transactionsRoot BINARY(32), receiptsRoot BINARY(32), logsBloom BINARY(128), difficulty BINARY(32), number BINARY(32), gasUsed BINARY(32), gasLimit BINARY(32), timestamp BINARY(32), extraData BINARY(32), mixHash BINARY(32), nonce BINARY(32))"
  
  private final static String OMMER_LOOKUP_TABLE_STR = "ommerLookUp (blockHash BINARY(32), index INTEGER, ommerHash BINARY(32), PRIMARY KEY (blockHash, index))"
  private final static String OMMER_TABLE_STR = "ommer (blockHash BINARY(32) PRIMARY KEY, parentHash BINARY(32), ommersHash BINARY(32), beneficiary BINARY(32), stateRoot BINARY(32), transactionsRoot BINARY(32), receiptsRoot BINARY(32), logsBloom BINARY(128), difficulty BINARY(32), number BINARY(32), gasUsed BINARY(32), gasLimit BINARY(32), timestamp BINARY(32), extraData BINARY(32), mixHash BINARY(32), nonce BINARY(32))"
  
  private final static String TRANSACTION_LOOKUP_TABLE_STR = "transactionLookUp (blockNumber BINARY(32), index INTEGER, transactionHash BINARY(32), PRIMARY KEY (blockNumber, index))"
  private final static String TRANSACTION_TABLE_STR = "transaction (transactionHash BINARY(32) PRIMARY KEY, nonce BINARY(32), gasPrice BINARY(32), gasLimit BINARY(32), recipient BINARY(32), value BINARY(32), v TINYINT, r BINARY(32), s BINARY(32), data LONGVARCHAR)"
  
  private final static String INSERT_BLOCK_LOOKUP_STMT_STR = "INSERT INTO blockLookUp VALUES (?, ?)"
  private final static String SELECT_BLOCK_LOOKUP_STMT_STR = "SELECT * FROM blockLookUp WHERE blockNumber=?"
  private final static String DELETE_BLOCK_LOOKUP_STMT_STR = "DELETE FROM blockLookUp WHERE blockNumber=?"
  
  private final static String INSERT_BLOCK_STMT_STR = "INSERT INTO block VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
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
  
  private final static String INSERT_TRANSACTION_STMT_STR = "INSERT INTO transaction VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
  private final static String SELECT_TRANSACTION_STMT_STR = "SELECT * FROM transaction WHERE transactionHash=?"
  private final static String DELETE_TRANSACTION_STMT_STR = "DELETE FROM transaction WHERE transactionHash=?"
  
  private final static TwoLevelDBCache<EVMWord, EVMWord> blockLookUp = new TwoLevelDBCache<EVMWord, EVMWord>(
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
  private final static TwoLevelDBCache<EVMWord, Block> block = new TwoLevelDBCache<EVMWord, Block>(
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
  private final static TwoLevelDBCache<Pair<EVMWord, Integer>, EVMWord> ommerLookUp = new TwoLevelDBCache<Pair<EVMWord, Integer>, EVMWord>(
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
  private final static TwoLevelDBCache<EVMWord, Block> ommer = new TwoLevelDBCache<EVMWord, Block>(
    MAX_OMMER_CACHE_SIZE,
    DataBaseID.CHAINDATA,
    "chain",
    OMMER_TABLE_STR,
    INSERT_OMMER_STMT_STR,
    [BlockchainData::fillBlockInsertStatement(it)],
    SELECT_OMMER_STMT_STR,
    [BlockchainData::fillBlockSelectStatement(it)],
    [BlockchainData::readBlockFromResultSet(it)],
    DELETE_OMMER_STMT_STR,
    [BlockchainData::fillBlockDeleteStatement(it)]
  )
  private final static TwoLevelDBCache<Pair<EVMWord, Integer>, EVMWord> transactionLookUp = new TwoLevelDBCache<Pair<EVMWord, Integer>, EVMWord>(
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
  private final static TwoLevelDBCache<EVMWord, Transaction> transaction = new TwoLevelDBCache<EVMWord, Transaction>(
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
  
  //BlockLookUp

  def private static PreparedStatement fillBlockLookUpInsertStatement(Triple<EVMWord, EVMWord, PreparedStatement> triple) {
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
  
  def private static EVMWord readBlockHashFromResultSet(Pair<ResultSet, EVMWord> pair) {
    val resultSet = pair.key
    
    try {
      resultSet.next
      
      new EVMWord(resultSet.getBytes("blockHash"))
    } catch (Exception e) {
      LOGGER.debug(e.message)
      null
    }
  }
  
  //Block

  def private static PreparedStatement fillBlockInsertStatement(Triple<EVMWord, Block, PreparedStatement> triple) {
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
  
  def private static PreparedStatement fillBlockSelectStatement(Pair<EVMWord, PreparedStatement> pair) {
    val blockHash = pair.key
    val stmt = pair.value
    
    stmt.setBytes(1, blockHash.toByteArray)
    
    stmt
  }
  
  def private static PreparedStatement fillBlockDeleteStatement(Pair<EVMWord, PreparedStatement> pair) {
    val blockHash = pair.key
    val stmt = pair.value
    
    stmt.setBytes(1, blockHash.toByteArray)
    
    stmt
  }
  
  def private static Block readBlockFromResultSet(Pair<ResultSet, EVMWord> pair) {
    val resultSet = pair.key
    
    try {
      resultSet.next
      
      val resultBlock = new Block()
      
      resultBlock.parentHash = new EVMWord(resultSet.getBytes("parentHash"))
      resultBlock.ommersHash = new EVMWord(resultSet.getBytes("ommersHash"))
      resultBlock.beneficiary = new EVMWord(resultSet.getBytes("beneficiary"))
      resultBlock.stateRoot = new EVMWord(resultSet.getBytes("stateRoot"))
      resultBlock.transactionsRoot = new EVMWord(resultSet.getBytes("transactionsRoot"))
      resultBlock.receiptsRoot = new EVMWord(resultSet.getBytes("receiptsRoot"))
      resultBlock.logsBloom = new Int2048(resultSet.getBytes("logsBloom"))
      resultBlock.difficulty = new EVMWord(resultSet.getBytes("difficulty"))
      resultBlock.number = new EVMWord(resultSet.getBytes("number"))
      resultBlock.gasUsed = new EVMWord(resultSet.getBytes("gasUsed"))
      resultBlock.gasLimit = new EVMWord(resultSet.getBytes("gasLimit"))
      resultBlock.timestamp = new EVMWord(resultSet.getBytes("timestamp"))
      resultBlock.extraData = resultSet.getBytes("extraData")
      resultBlock.mixHash = new EVMWord(resultSet.getBytes("mixHash"))
      resultBlock.nonce = new EVMWord(resultSet.getBytes("nonce"))
      
      resultBlock
    } catch (Exception e) {
      LOGGER.debug(e.message)
      null
    }
  }
  
  //Ommer

  def private static PreparedStatement fillOmmerLookUpInsertStatement(Triple<Pair<EVMWord, Integer>, EVMWord, PreparedStatement> triple) {
    val blockHash = triple.left.key
    val index = triple.left.value
    val ommerHash = triple.middle
    val stmt = triple.right
    
    stmt.setBytes(1, blockHash.toByteArray)
    stmt.setInt(2, index)
    stmt.setBytes(3, ommerHash.toByteArray)
    
    stmt
  }
  
  def private static PreparedStatement fillOmmerLookUpSelectStatement(Pair<Pair<EVMWord, Integer>, PreparedStatement> pair) {
    val blockHash = pair.key.key
    val index = pair.key.value
    val stmt = pair.value
    
    stmt.setBytes(1, blockHash.toByteArray)
    stmt.setInt(2, index)
    
    stmt
  }
  
  def private static PreparedStatement fillOmmerLookUpDeleteStatement(Pair<Pair<EVMWord, Integer>, PreparedStatement> pair) {
    val blockHash = pair.key.key
    val index = pair.key.value
    val stmt = pair.value
    
    stmt.setBytes(1, blockHash.toByteArray)
    stmt.setInt(2, index)
    
    stmt
  }
  
  def private static EVMWord readOmmerLookUpHashFromResultSet(Pair<ResultSet, Pair<EVMWord, Integer>> pair) {
    val resultSet = pair.key
    
    try {
      resultSet.next
      
      new EVMWord(resultSet.getBytes("ommerHash"))
    } catch (Exception e) {
      LOGGER.debug(e.message)
      null
    }
  }
  
  //TransactionLookUp

  def private static PreparedStatement fillTransactionLookUpInsertStatement(Triple<Pair<EVMWord, Integer>, EVMWord, PreparedStatement> triple) {
    val blockHash = triple.left.key
    val index = triple.left.value
    val transactionHash = triple.middle
    val stmt = triple.right
    
    stmt.setBytes(1, blockHash.toByteArray)
    stmt.setInt(2, index)
    stmt.setBytes(3, transactionHash.toByteArray)
    
    stmt
  }
  
  def private static PreparedStatement fillTransactionLookUpSelectStatement(Pair<Pair<EVMWord, Integer>, PreparedStatement> pair) {
    val blockHash = pair.key.key
    val index = pair.key.value
    val stmt = pair.value
    
    stmt.setBytes(1, blockHash.toByteArray)
    stmt.setInt(2, index)
    
    stmt
  }
  
  def private static PreparedStatement fillTransactionLookUpDeleteStatement(Pair<Pair<EVMWord, Integer>, PreparedStatement> pair) {
    val blockHash = pair.key.key
    val index = pair.key.value
    val stmt = pair.value
    
    stmt.setBytes(1, blockHash.toByteArray)
    stmt.setInt(2, index)
    
    stmt
  }
  
  def private static EVMWord readTransactionHashFromResultSet(Pair<ResultSet, Pair<EVMWord, Integer>> pair) {
    val resultSet = pair.key
    
    try {
      resultSet.next
      
      new EVMWord(resultSet.getBytes("transactionHash"))
    } catch (Exception e) {
      LOGGER.debug(e.message)
      null
    }
  }
  
  //Transaction

  def private static PreparedStatement fillTransactionInsertStatement(Triple<EVMWord, Transaction, PreparedStatement> triple) {
    val transactionHash = triple.left
    val transaction = triple.middle
    val stmt = triple.right
    
    stmt.setBytes(1, transactionHash.toByteArray)
    stmt.setBytes(2, transaction.nonce.toByteArray)
    stmt.setBytes(3, transaction.gasPrice.toByteArray)
    stmt.setBytes(4, transaction.gasLimit.toByteArray)
    stmt.setBytes(5, if (transaction.to !== null) transaction.to.toByteArray)
    stmt.setBytes(6, transaction.value.toByteArray)
    stmt.setInt(7, transaction.v.intValue)
    stmt.setBytes(8, transaction.r.toByteArray)
    stmt.setBytes(9, transaction.s.toByteArray)
    stmt.setBytes(10, transaction.getData().map[byteValue])
    
    stmt
  }
  
  def private static PreparedStatement fillTransactionSelectStatement(Pair<EVMWord, PreparedStatement> pair) {
    val transactionHash = pair.key
    val stmt = pair.value
    
    stmt.setBytes(1, transactionHash.toByteArray)
    
    stmt
  }
  
  def private static PreparedStatement fillTransactionDeleteStatement(Pair<EVMWord, PreparedStatement> pair) {
    val transactionHash = pair.key
    val stmt = pair.value
    
    stmt.setBytes(1, transactionHash.toByteArray)
    
    stmt
  }
  
  def private static Transaction readTransactionFromResultSet(Pair<ResultSet, EVMWord> pair) {
    val resultSet = pair.key
    
    try {
      resultSet.next
      
      val resultTransaction = new Transaction()
      
      resultTransaction.nonce = new EVMWord(resultSet.getBytes("nonce"))
      resultTransaction.gasPrice = new EVMWord(resultSet.getBytes("gasPrice"))
      resultTransaction.gasLimit = new EVMWord(resultSet.getBytes("gasLimit"))
      val _to = resultSet.getBytes("to")
      resultTransaction.to = if (_to !== null) new EVMWord(_to) 
      resultTransaction.value = new EVMWord(resultSet.getBytes("value"))
      resultTransaction.v = new UnsignedByte(resultSet.getInt("v"))
      resultTransaction.r = new EVMWord(resultSet.getBytes("r"))
      resultTransaction.s = new EVMWord(resultSet.getBytes("s"))
      resultTransaction.data = resultSet.getBytes("data").map[new UnsignedByte(it)]
      resultTransaction.isData = _to !== null
      
      resultTransaction
    } catch (Exception e) {
      LOGGER.debug(e.message)
      null
    }
  }
  
  def private static void persistOmmer(EVMWord blockHash, Integer index) {
    val ommerBlock = eth_getUncleByBlockHashAndIndex(blockHash, new EVMWord(index))
    persistOmmer(ommerBlock, ommerBlock.hash, blockHash, index)
  }
  
  def private static void persistOmmer(Block b, EVMWord ommerHash, EVMWord blockHash, Integer index) {
    ommerLookUp.put(Pair.of(blockHash, index), ommerHash)
    if (ommer.lookUp(ommerHash) === null) {
      ommer.put(ommerHash, b)
    }
  }
  
  def private static void persistBlock(Block b, EVMWord blockHash) {
    block.put(blockHash, b)
    blockLookUp.put(b.number, blockHash)
    for (var i = 0; i < b.ommers.size; i++) {
      if (ommerLookUp.lookUp(Pair.of(blockHash, i)) === null) {
        persistOmmer(blockHash, i)
      }
    }
    for (var i = 0; i < b.transactions.size; i++) {
      val transactionHash = b.transactions.get(i).hash
      transactionLookUp.put(Pair.of(blockHash, i), transactionHash)
      transaction.put(transactionHash, b.transactions.get(i))
    }
  }
  
  def private static void persistTransaction(Transaction t, EVMWord transactionHash, EVMWord blockHash, Integer index) {
    transactionLookUp.put(Pair.of(blockHash, index), transactionHash)
    if (transaction.lookUp(transactionHash) === null) {
      transaction.put(transactionHash, t)
    }
  }
  
  def static Block getBlockByHash(EVMWord blockHash) {
    var resultBlock = block.lookUp(blockHash)
    if (resultBlock === null) {
      resultBlock = eth_getBlockByHash(blockHash)
      persistBlock(resultBlock, blockHash)
    }
    
    resultBlock
  }
  
  def static EVMWord getBlockHashByNumber(EVMWord blockNumber) {
    blockLookUp.lookUp(blockNumber) ?: eth_getBlockByNumber_hash(blockNumber, null)
  }
  
  def static Block getBlockByNumber(EVMWord blockNumber) { 
    getBlockByHash(getBlockHashByNumber(blockNumber))
  }
  
  def static Block getOmmerByBlockNumberAndIndex(EVMWord blockNumber, Integer index) {
    var resultBlock = ommer.lookUp(ommerLookUp.lookUp(Pair.of(blockNumber, index)))
    if (resultBlock === null) {
      resultBlock = eth_getUncleByBlockHashAndIndex(blockNumber, new EVMWord(index))
      persistOmmer(resultBlock, resultBlock.hash, blockNumber, index)
    }
    
    resultBlock
  }
  
  def static Transaction getTransactionByHash(EVMWord transactionHash) {
    var resultTransaction = transaction.lookUp(transactionHash)
    if (resultTransaction === null) {
      resultTransaction = eth_getTransactionByHash(transactionHash)
      if (transaction.lookUp(transactionHash) === null) {
        transaction.put(transactionHash, resultTransaction)
      }
    }
    
    resultTransaction
  }
  
  def static Transaction getTransactionByBlockNumberAndIndex(EVMWord blockHash, Integer index) {
    var transactionHash = transactionLookUp.lookUp(Pair.of(blockHash, index))
    var resultTransaction = transaction.lookUp(transactionHash)
    if (transactionHash === null) {
      resultTransaction = eth_getTransactionByBlockNumberAndIndex(blockHash, null, new EVMWord(index))
      persistTransaction(resultTransaction, transactionHash, blockHash, index)
    }
    
    resultTransaction
  }
  
  def static void flush() {
    //TODO: shutdown hook
    blockLookUp.flush
    block.flush
    ommerLookUp.flush
    ommer.flush
    transactionLookUp.flush
    transaction.flush
  }
}








