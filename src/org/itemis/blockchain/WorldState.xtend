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

import org.itemis.types.impl.EVMWord
import org.itemis.types.UnsignedByte
import org.itemis.ressources.MainnetAllocData
import org.itemis.utils.db.DataBaseWrapper.DataBaseID
import org.itemis.utils.db.TwoLevelDBCache
import org.apache.commons.lang3.tuple.Triple
import java.sql.PreparedStatement
import org.itemis.types.UnsignedByteList
import java.sql.ResultSet
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.itemis.evm.utils.MerklePatriciaTrie
import com.google.common.cache.CacheBuilder
import org.itemis.utils.db.DataBaseWrapper
import org.itemis.ressources.JsonRPCWrapper
import java.util.Map
import org.itemis.types.NibbleList
import org.itemis.evm.utils.MerklePatriciaTrie.Leaf
import org.itemis.utils.Utils
import org.itemis.evm.utils.EVMUtils
import org.eclipse.xtend.lib.annotations.Accessors
import com.google.common.cache.Cache
import org.itemis.types.impl.Address
import org.itemis.types.impl.Hash256
import java.io.FilenameFilter
import java.io.File

class WorldState {
  extension Utils u = new Utils
  extension EVMUtils e = new EVMUtils
  extension DataBaseWrapper db = new DataBaseWrapper
  extension JsonRPCWrapper j = new JsonRPCWrapper
  
  private final static Logger LOGGER = LoggerFactory.getLogger("Database")

  private final static int MAX_ACCOUNT_CACHE_SIZE = 100
  private final static int MAX_ACCOUNT_DB_CACHE_SIZE = 100
  private final static int MAX_CODE_DB_CACHE_SIZE    = 10
  private final static int MAX_STORAGE_CACHE_SIZE = 100

  private final static String ACCOUNT_TABLE_STR = "accounts (address BINARY(20) PRIMARY KEY, creationBlock BIGINT NOT NULL)"
  private final static String CODE_TABLE_STR    = "code (address BINARY(20) PRIMARY KEY, code LONGVARBINARY)"
  
  private final static String INSERT_ACCOUNT_STMT_STR = "INSERT INTO accounts VALUES (?, ?)"
  private final static String SELECT_ACCOUNT_STMT_STR = "SELECT * FROM accounts WHERE address=?"
  private final static String DELETE_ACCOUNT_STMT_STR = "DELETE FROM accounts WHERE address=?"
  
  private final static String INSERT_CODE_STMT_STR = "INSERT INTO code VALUES (?, ?)"
  private final static String SELECT_CODE_STMT_STR = "SELECT * FROM code WHERE address=?"
  private final static String DELETE_CODE_STMT_STR = "DELETE FROM code WHERE address=?"
  
  private final String name
  private final MerklePatriciaTrie accountTrie
  private final Cache<Address, Account> accountCache = CacheBuilder.newBuilder().maximumSize(MAX_ACCOUNT_CACHE_SIZE).build()
  private final TwoLevelDBCache<Address, Long> accountDB
  private final TwoLevelDBCache<Address, UnsignedByteList> codeDB
  private final Map<Address, MerklePatriciaTrie> storageTries = newHashMap
  private final Cache<Pair<Address, EVMWord>, EVMWord> storageCache = CacheBuilder.newBuilder().maximumSize(MAX_STORAGE_CACHE_SIZE).build()
      
  @Accessors private EVMWord currentBlockNumber = EVMWord.ZERO
  @Accessors private EVMWord executedTransactions = EVMWord.ZERO //in this block
  
  new(String name) {
    this.name = name
    
    this.accountTrie = new MerklePatriciaTrie(name + "_accountTrie")
    for (storageTrie: DataBaseWrapper.getLocation(DataBaseID.TRIE, name + "_accountTrie").parentFile.list(new FilenameFilter() {
      override accept(File dir, String filename) {
        filename.startsWith(name + "_storageTrie")
      }
    })) {
      val addr = new Address(storageTrie.split("_").last.fromHex)
      this.storageTries.put(addr, new MerklePatriciaTrie(storageTrie))
    }
    
    this.accountDB = new TwoLevelDBCache<Address, Long>(
      MAX_ACCOUNT_DB_CACHE_SIZE,
      DataBaseID.STATE,
      name,
      ACCOUNT_TABLE_STR,
      INSERT_ACCOUNT_STMT_STR,
      [WorldState::fillAccountInsertStatement(it)],
      SELECT_ACCOUNT_STMT_STR,
      [WorldState::fillAccountSelectStatement(it)],
      [WorldState::readAccountFromResultSet(it)],
      DELETE_ACCOUNT_STMT_STR,
      [WorldState::fillAccountDeleteStatement(it)]
    )
    
    this.codeDB = new TwoLevelDBCache<Address, UnsignedByteList>(
      MAX_CODE_DB_CACHE_SIZE,
      DataBaseID.STATE,
      name,
      CODE_TABLE_STR,
      INSERT_CODE_STMT_STR,
      [WorldState::fillCodeInsertStatement(it)],
      SELECT_CODE_STMT_STR,
      [WorldState::fillCodeSelectStatement(it)],
      [WorldState::readCodeFromResultSet(it)],
      DELETE_CODE_STMT_STR,
      [WorldState::fillCodeDeleteStatement(it)]
    )
  }
  
  //ACCOUNT
  
  private static def PreparedStatement fillAccountInsertStatement(Triple<Address, Long, PreparedStatement> triple) {
    val address = triple.left
    val creationBlock = triple.middle
    val stmt = triple.right
    
    stmt.setBytes(1, address.toUnsignedByteArray.map[byteValue])
    stmt.setLong(2, creationBlock)
    
    stmt
  }
  
  private static def PreparedStatement fillAccountSelectStatement(Pair<Address, PreparedStatement> pair) {
    val address = pair.key
    val stmt = pair.value
    
    stmt.setBytes(1, address.toUnsignedByteArray.map[byteValue])
    
    stmt
  }
  
  private static def PreparedStatement fillAccountDeleteStatement(Pair<Address, PreparedStatement> pair) {
    val address = pair.key
    val stmt = pair.value
    
    stmt.setBytes(1, address.toUnsignedByteArray.map[byteValue])
    
    stmt
  }
  
  private static def Long readAccountFromResultSet(Pair<ResultSet, Address> pair) {
    val resultSet = pair.key
    val address = pair.value
    
    try {
      resultSet.next
      
      if (!address.equals(new Address(resultSet.getBytes("address")))) {
        throw new IllegalArgumentException("address unequal")
      }
      
      resultSet.getLong("creationBlock")
    } catch (Exception e) {
      LOGGER.info(e.message)
      null
    }
  }
  
  //CODE
  
  private static def PreparedStatement fillCodeInsertStatement(Triple<Address, UnsignedByteList, PreparedStatement> triple) {
    val address = triple.left
    val code = triple.middle
    val stmt = triple.right
    
    stmt.setBytes(1, address.toByteArray)
    stmt.setBytes(2, code.elements.map[byteValue] as byte[])
    
    stmt
  }
  
  private static def PreparedStatement fillCodeSelectStatement(Pair<Address, PreparedStatement> pair) {
    val address = pair.key
    val stmt = pair.value
    
    stmt.setBytes(1, address.toUnsignedByteArray.map[byteValue])
    
    stmt
  }
  
  private static def PreparedStatement fillCodeDeleteStatement(Pair<Address, PreparedStatement> pair) {
    val address = pair.key
    val stmt = pair.value
    
    stmt.setBytes(1, address.toUnsignedByteArray.map[byteValue])
    
    stmt
  }
  
  private static def UnsignedByteList readCodeFromResultSet(Pair<ResultSet, Address> pair) {
    val resultSet = pair.key
    val address = pair.value
    
    try {
      resultSet.next
      
      if (!address.equals(new EVMWord(resultSet.getBytes("address")))) {
        throw new IllegalArgumentException("address unequal")
      }
      
      val code = resultSet.getBytes("code")
      if (code !== null) {
        new UnsignedByteList(code.map[new UnsignedByte(it)])
      } else {
        new UnsignedByteList()
      }
    } catch (Exception e) {
      LOGGER.info(e.message)
      null
    }
  }
  
  def loadGenesisState(boolean ignoreDuplicates) {
    val iter = MainnetAllocData.mainnetAllocDataQueryIterator
    while(iter.hasNext) {
      val e = iter.next
      
      val address = e.key
      val balance = e.value
      val account = new Account(balance)
      
      if (ignoreDuplicates || !accountExists(address)) {
        putAccount(EVMWord.ZERO, address, account)
      }
    }
  }
  
  //for new accounts
  def void putAccount(EVMWord blockNumber, Address address, Account account) {
    accountCache.put(address, account)
    accountDB.put(address, blockNumber.longValue)
    account.insertIntoTrie(accountTrie, address)
  }
  
  //for overwriting accounts
  def void setAccount(Address address, Account account) {
    if (!accountExists(address)) {
      putAccount(currentBlockNumber.dec, address, account)
    } else {
      account.insertIntoTrie(accountTrie, address)
    }
  }
  
  def void deleteAccount(Address address) {
    getAccount(address).removeFromTrie(accountTrie, address)
    accountCache.invalidate(address)
    accountCache.cleanUp
    accountDB.remove(address)
  }
  
  def boolean accountExists(Address address) {
    accountDB.lookUp(address) !== null 
  }
  
  def boolean accountExists(EVMWord blockNumber, Address address) {
    accountDB.lookUp(address) <= blockNumber.longValue
  }
  
  def long getAccountCount() {
    getAccountCount(null)
  }
  
  def long getAccountCount(Long blockNumber) {
    accountDB.flush
    val conn = DataBaseWrapper.getConnection(DataBaseID.STATE, name)
    
    val query = if (blockNumber === null) {
      "SELECT COUNT(*) FROM accounts"
    } else {
      "SELECT COUNT(*) FROM accounts WHERE creationBlock <= " + blockNumber
    }
    val result = conn.query(query)
    try {
      result.next
      result.getLong(1)
    } catch (Exception e) {
      0L
    }
  }
  
  def Account getAccount(Address address) {
    accountCache.getIfPresent(address) ?: getAccount(accountTrie.trieRoot, address)
  }
  
  def Account getAccount(Long blockNumber, Address address) {
    getAccount(eth_getBlockByNumber(new EVMWord(blockNumber), null).stateRoot, address)
  }
  
  def Account getAccount(Hash256 rootHash, Address address) {
    val account = new Account(accountTrie, rootHash, address)
    accountCache.put(address, account)
    account
  }
  
  def Hash256 getStateRoot() {
    accountTrie.trieRoot
  }
  
  private def getStorageTrie(Address address) {
    var trie = storageTries.get(address)
    if (trie === null) {
      trie = new MerklePatriciaTrie(name + "_storageTrie_" + address.toHexString)
      storageTries.put(address, trie)
    }
    trie
  }
  
  def UnsignedByteList getCodeAt(Address address) {
    codeDB.lookUp(address) ?: new UnsignedByteList(newByteArrayOfSize(0))
  }
  
  def void setCodeAt(Address address, String code) {
    setCodeAt(address, new UnsignedByteList(code.fromHex.map[new UnsignedByte(it)]))
  }
  
  def void setCodeAt(Address address, UnsignedByteList code) {
    codeDB.put(address, code)
    
    val acc = getAccount(address)
    acc.codeHash = keccak256(code.elements.map[byteValue])
    acc.insertIntoTrie(accountTrie, address)
  }
  
  def Map<EVMWord, EVMWord> getStorage(Address address) {
    val trie = address.storageTrie
    
    try {
      val result = newHashMap
      trie.root.getNodes(trie).entrySet.forEach[{
        val _key = new EVMWord(key.toUnsignedBytes)
        val _value = new EVMWord(value)
        
        result.put(_key, _value)
      }]
      result
    } catch (Exception e) {
      null
    }
  }
  
  def EVMWord getStorageAt(Address address, EVMWord offset) {
    storageCache.getIfPresent(Pair.of(address, offset)) ?: getStorageAt(address.storageTrie.trieRoot, address, offset)
  }
  
  def EVMWord getStorageAt(Hash256 rootHash, Address address, EVMWord offset) {
    val trie = address.storageTrie
    
    try {
      val nodeValue = (trie.getNode(new UnsignedByteList(rootHash.toUnsignedByteArray)).getNode(trie, new NibbleList(offset)) as Leaf).value
      val tree = reverseRLP(nodeValue)
      val value = new EVMWord(tree.children.get(0).data)
      storageCache.put(Pair.of(address, offset), value)
      value
    } catch (Exception e) {
      if (e.toString.contains("ResultSet is empty") || e instanceof NullPointerException) {
        EVMWord.ZERO
      } else {
        throw e
      }
    }
  }
  
  def void setStorageAt(Address address, EVMWord offset, EVMWord value) {
    var trie = address.storageTrie
    trie.putElement(new NibbleList(offset.toByteArray.keccak256.toByteArray), value.trimTrailingZerosAndReverse.rlp)
    
    val acc = getAccount(address)
    acc.storageRoot = trie.trieRoot
    acc.insertIntoTrie(accountTrie, address)
    
    storageCache.put(Pair.of(address, offset), value)
  }
  
  def void setCurrentBlock(EVMWord currentBlock) {
    currentBlockNumber = currentBlock
  }
  
  def void incCurrentBlock() {
    currentBlockNumber = currentBlockNumber.inc
  }
  
  def void incExecutedTransaction() {
    executedTransactions = executedTransactions.inc
  }
  
  def void copyTo(String name) {
    accountTrie.copyTo(String.format("%s_accountTrie", name))
    
    accountDB.flush
    codeDB.flush
    copyDB(DataBaseID.STATE, this.name, name)
    
    for (storageTrie: storageTries.entrySet.map[value]) {
      storageTrie.copyTo(String.format("%s_%s", name, storageTrie.location.toPath.fileName.toString.split("_").tail.join("_")))
    }
  }
  
  def static void copy(String from, String to) {
    new WorldState(from).copyTo(to)
  }
  
  def void delete() {
    accountTrie.delete
    accountDB.delete
    codeDB.delete
    for (storageTrie: storageTries.entrySet.map[value]) {
      storageTrie.delete
    }
  }
  
  def static boolean exists(String name) {
    DataBaseWrapper.getLocation(DataBaseID.STATE, name).exists
  }
}
