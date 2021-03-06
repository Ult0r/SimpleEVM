/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.ressources

import com.google.gson.JsonElement
import org.itemis.types.impl.EVMWord
import java.util.Optional
import java.util.List
import org.itemis.types.UnsignedByte
import org.itemis.utils.Utils
import org.itemis.blockchain.Block
import org.itemis.blockchain.Transaction
import org.itemis.blockchain.TransactionReceipt
import org.itemis.types.impl.Address
import org.itemis.types.impl.Hash256

//documented by: https://github.com/ethereum/wiki/wiki/JSON-RPC
class JsonRPCWrapper {
  extension DataFetch d = new DataFetch
  extension Utils u = new Utils

  private static final String JSONRPC_VERSION = "2.0"

  // Wrapping API calls
  def private JsonElement wrapDataFetch(String method) {
    wrapDataFetch(method, "[]")
  }

  def private JsonElement wrapDataFetch(String method, String params) {
    wrapDataFetch(1, method, params)
  }

  def private JsonElement wrapDataFetch(int id, String method, String params) {
    val postData = String.format('{"jsonrpc":"%s","method":"%s","params":%s,"id":%d}', JSONRPC_VERSION, method, params, id)
    fetchData(postData)
  }

  private def String displayEVMWordAsNumber(EVMWord word) {
    displayEVMWordAsNumber(word, true)
  }

  private def String displayEVMWordAsNumber(EVMWord word, boolean fullyTrimmed) {
    if (fullyTrimmed) {
      "0x" + word.toBigInteger.toString(16)
    } else {
      word.reverse.toString
    }
  }

  // HELPER
  def String identifyBlock(EVMWord blockNumber, String tag) {
    if(blockNumber !== null) {
      blockNumber.displayEVMWordAsNumber
    } else if(tag !== null) {
      if(tag != "latest" && tag != "earliest" && tag != "pending") {
        throw new IllegalArgumentException(tag + " is not a valid block identifier")
      } else {
        tag
      }
    } else {
      throw new IllegalArgumentException("both parameters are null")
    }
  }

  // METHODS
  def String web3_clientVersion() {
    wrapDataFetch("web3_clientVersion").asJsonObject.get("result").asString
  }

  def Hash256 web3_sha3(String data) {
    val params = String.format('["%s"]', data)
    Hash256.fromString(wrapDataFetch("web3_sha3", params).asJsonObject.get("result").asString)
  }

  def String net_version() {
    wrapDataFetch("net_version").asJsonObject.get("result").asString
  }

  def boolean net_listening() {
    wrapDataFetch("net_listening").asJsonObject.get("result").asBoolean
  }

  def EVMWord net_peerCount() {
    EVMWord.fromString(wrapDataFetch("net_peerCount").asJsonObject.get("result").asString)
  }

  def String eth_protocolVersion() {
    wrapDataFetch("eth_protocolVersion").asJsonObject.get("result").asString
  }

  def JsonElement eth_syncing() {
    wrapDataFetch("eth_syncing").asJsonObject.get("result")
  }

  def Optional<EVMWord> eth_syncing_startingBlock() {
    val sync = eth_syncing
    try {
      sync.asBoolean
      Optional.empty
    } catch(Exception e) {
      Optional.of(EVMWord.fromString(sync.asJsonObject.get("startingBlock").asString))
    }
  }

  def Optional<EVMWord> eth_syncing_currentBlock() {
    val sync = eth_syncing
    try {
      sync.asBoolean
      Optional.empty
    } catch(Exception e) {
      Optional.of(EVMWord.fromString(sync.asJsonObject.get("currentBlock").asString))
    }
  }

  def Optional<EVMWord> eth_syncing_highestBlock() {
    val sync = eth_syncing
    try {
      sync.asBoolean
      Optional.empty
    } catch(Exception e) {
      Optional.of(EVMWord.fromString(sync.asJsonObject.get("highestBlock").asString))
    }
  }

  def Address eth_coinbase() {
    throw new UnsupportedOperationException("eth_coinbase: 405 - method not allow")
  }

  def boolean eth_mining() {
    wrapDataFetch("eth_mining").asJsonObject.get("result").asBoolean
  }

  def EVMWord eth_hashrate() {
    EVMWord.fromString(wrapDataFetch("eth_hashrate").asJsonObject.get("result").asString)
  }

  def EVMWord eth_gasPrice() {
    EVMWord.fromString(wrapDataFetch("eth_gasPrice").asJsonObject.get("result").asString)
  }

  def List<Address> eth_accounts() {
    wrapDataFetch("eth_accounts").asJsonObject.get("result").asJsonArray.toList.map[Address.fromString(it.asString)]
  }

  def EVMWord eth_blockNumber() {
    new EVMWord(fromHex(wrapDataFetch("eth_blockNumber").asJsonObject.get("result").asString).reverseView)
  }

  def EVMWord eth_getBalance(Address address, EVMWord blockNumber, String tag) {
    val params = String.format('["%s","%s"]', address, identifyBlock(blockNumber, tag))
    new EVMWord(wrapDataFetch("eth_getBalance", params).asJsonObject.get("result").asString.fromHex(true).reverseView)
  }

  def EVMWord eth_getStorageAt(Address address, EVMWord offset, EVMWord blockNumber, String tag) {
    val params = String.format('["%s","%s","%s"]', address, offset.displayEVMWordAsNumber,
      identifyBlock(blockNumber, tag))
    EVMWord.fromString(wrapDataFetch("eth_getStorageAt", params).asJsonObject.get("result").asString)
  }

  def EVMWord eth_getTransactionCount(Address address, EVMWord blockNumber, String tag) {
    val params = String.format('["%s","%s"]', address, identifyBlock(blockNumber, tag))
    new EVMWord(
      wrapDataFetch("eth_getTransactionCount", params).asJsonObject.get("result").asString.fromHex.reverseView)
  }

  def EVMWord eth_getBlockTransactionCountByHash(Hash256 blockHash) {
    val params = String.format('["%s"]', blockHash.toString)
    EVMWord.fromString(wrapDataFetch("eth_getBlockTransactionCountByHash", params).asJsonObject.get("result").asString)
  }

  def EVMWord eth_getBlockTransactionCountByNumber(EVMWord blockNumber, String tag) {
    val params = String.format('["%s"]', identifyBlock(blockNumber, tag))
    EVMWord.fromString(
      wrapDataFetch("eth_getBlockTransactionCountByNumber", params).asJsonObject.get("result").asString)
  }

  def EVMWord eth_getUncleCountByBlockHash(Hash256 blockHash) {
    val params = String.format('["%s"]', blockHash.toString)
    new EVMWord(
      wrapDataFetch("eth_getUncleCountByBlockHash", params).asJsonObject.get("result").asString.fromHex.reverseView)
  }

  def EVMWord eth_getUncleCountByBlockNumber(EVMWord blockNumber, String tag) {
    val params = String.format('["%s"]', identifyBlock(blockNumber, tag))
    new EVMWord(
      wrapDataFetch("eth_getUncleCountByBlockNumber", params).asJsonObject.get("result").asString.fromHex.reverseView)
  }

  def UnsignedByte[] eth_getCode(Address address, EVMWord blockNumber, String tag) {
    val params = String.format('["%s","%s"]', address, identifyBlock(blockNumber, tag))
    wrapDataFetch("eth_getCode", params).asJsonObject.get("result").asString.fromHex.map[new UnsignedByte(it)]
  }

  def UnsignedByte[] eth_sign(Address address, UnsignedByte[] message) {
    throw new UnsupportedOperationException("eth_sign: 405 - method not allow")
  }

  def EVMWord eth_sendTransaction(Address from, Address to, EVMWord gas, EVMWord gasPrice, EVMWord value,
    UnsignedByte[] data) {
    throw new UnsupportedOperationException("eth_sendTransaction: 405 - method not allow")
  }

  def EVMWord eth_sendRawTransaction(UnsignedByte[] signedData) {
    throw new UnsupportedOperationException("eth_sendRawTransaction: 405 - method not allow")
  }

  def UnsignedByte[] eth_call(Address from, Address to, EVMWord gas, EVMWord gasPrice, EVMWord value,
    UnsignedByte[] data, EVMWord blockNumber, String tag) {
    val params = String.format(
      '[{"from":"%s","to":"%s","gas":"%s","gasPrice":"%s","value":"%s","data":"%s"},"%s"]',
      from,
      to,
      gas.displayEVMWordAsNumber,
      gasPrice.displayEVMWordAsNumber,
      value.displayEVMWordAsNumber,
      data.toHex,
      identifyBlock(blockNumber, tag)
    )
    wrapDataFetch("eth_call", params).asJsonObject.get("result").asString.fromHex.map[new UnsignedByte(it)]
  }

  def EVMWord eth_estimateGas(Address from, Address to, EVMWord gas, EVMWord gasPrice, EVMWord value,
    UnsignedByte[] data) {
    val params = String.format(
      '[{"from":"%s","to":"%s","gas":"%s","gasPrice":"%s","value":"%s","data":"%s"}]',
      from,
      to,
      gas.displayEVMWordAsNumber,
      gasPrice.displayEVMWordAsNumber,
      value.displayEVMWordAsNumber,
      data.toHex
    )
    EVMWord.fromString(wrapDataFetch("eth_estimateGas", params).asJsonObject.get("result").asString)
  }

  def Block eth_getBlockByHash(Hash256 blockHash) {
    val params = String.format('["%s", true]', blockHash.toString)
    val fetchResult = wrapDataFetch("eth_getBlockByHash", params).asJsonObject.get("result").asJsonObject

    new Block(fetchResult)
  }

  def EVMWord eth_getBlockByHash_totalDifficulty(Hash256 blockHash) {
    val params = String.format('["%s", false]', blockHash.toString)
    val fetchResult = wrapDataFetch("eth_getBlockByHash", params).asJsonObject.get("result").asJsonObject
    EVMWord.fromString(fetchResult.get("totalDifficulty").asString)
  }

  def EVMWord eth_getBlockByHash_size(Hash256 blockHash) {
    val params = String.format('["%s", false]', blockHash)
    val fetchResult = wrapDataFetch("eth_getBlockByHash", params).asJsonObject.get("result").asJsonObject
    new EVMWord(fetchResult.get("size").asString.fromHex.reverseView)
  }

  def List<EVMWord> eth_getBlockByHash_transactionHashes(Hash256 blockHash) {
    val params = String.format('["%s", false]', blockHash.toString)
    val fetchResult = wrapDataFetch("eth_getBlockByHash", params).asJsonObject.get("result").asJsonObject
    fetchResult.get("transactions").asJsonArray.toList.map[EVMWord.fromString(it.asString)]
  }

  def Block eth_getBlockByNumber(EVMWord blockNumber, String tag) {
    val params = String.format('["%s", true]', identifyBlock(blockNumber, tag).toString)
    val fetchResult = wrapDataFetch("eth_getBlockByNumber", params).asJsonObject.get("result").asJsonObject

    new Block(fetchResult)
  }

  def Hash256 eth_getBlockByNumber_hash(EVMWord blockNumber, String tag) {
    val params = String.format('["%s", false]', identifyBlock(blockNumber, tag).toString)
    val fetchResult = wrapDataFetch("eth_getBlockByNumber", params).asJsonObject.get("result").asJsonObject
    Hash256.fromString(fetchResult.get("hash").asString)
  }

  def EVMWord eth_getBlockByNumber_totalDifficulty(EVMWord blockNumber, String tag) {
    val params = String.format('["%s", false]', identifyBlock(blockNumber, tag).toString)
    val fetchResult = wrapDataFetch("eth_getBlockByNumber", params).asJsonObject.get("result").asJsonObject
    EVMWord.fromString(fetchResult.get("totalDifficulty").asString)
  }

  def EVMWord eth_getBlockByNumber_size(EVMWord blockNumber, String tag) {
    val params = String.format('["%s", false]', identifyBlock(blockNumber, tag))
    val fetchResult = wrapDataFetch("eth_getBlockByNumber", params).asJsonObject.get("result").asJsonObject
    new EVMWord(fetchResult.get("size").asString.fromHex.reverseView)
  }

  def List<EVMWord> eth_getBlockByNumber_transactionHashes(EVMWord blockNumber, String tag) {
    val params = String.format('["%s", false]', identifyBlock(blockNumber, tag).toString)
    val fetchResult = wrapDataFetch("eth_getBlockByNumber", params).asJsonObject.get("result").asJsonObject
    fetchResult.get("transactions").asJsonArray.toList.map[EVMWord.fromString(it.asString)]
  }

  def Transaction eth_getTransactionByHash(Hash256 transactionHash) {
    val params = String.format('["%s"]', transactionHash)
    new Transaction(wrapDataFetch("eth_getTransactionByHash", params).asJsonObject.get("result").asJsonObject)
  }

  def Transaction eth_getTransactionByBlockHashAndIndex(Hash256 blockHash, EVMWord index) {
    val params = String.format('["%s","%s"]', blockHash.toString, index.displayEVMWordAsNumber)
    new Transaction(
      wrapDataFetch("eth_getTransactionByBlockHashAndIndex", params).asJsonObject.get("result").asJsonObject)
  }

  def Transaction eth_getTransactionByBlockNumberAndIndex(EVMWord blockNumber, String tag, EVMWord index) {
    val params = String.format('["%s","%s"]', identifyBlock(blockNumber, tag), index.displayEVMWordAsNumber)
    new Transaction(
      wrapDataFetch("eth_getTransactionByBlockNumberAndIndex", params).asJsonObject.get("result").asJsonObject)
  }

  def TransactionReceipt eth_getTransactionReceipt(Hash256 transactionHash) {
    val params = String.format('["%s"]', transactionHash.toString)
    new TransactionReceipt(wrapDataFetch("eth_getTransactionReceipt", params).asJsonObject.get("result").asJsonObject)
  }

  def Block eth_getUncleByBlockHashAndIndex(Hash256 blockHash, EVMWord index) {
    val params = String.format('["%s","%s"]', blockHash.toString, index.displayEVMWordAsNumber)
    new Block(wrapDataFetch("eth_getUncleByBlockHashAndIndex", params).asJsonObject.get("result").asJsonObject)
  }

  def Block eth_getUncleByBlockNumberAndIndex(EVMWord blockNumber, String tag, EVMWord index) {
    val params = String.format('["%s","%s"]', identifyBlock(blockNumber, tag), index.displayEVMWordAsNumber)
    new Block(wrapDataFetch("eth_getUncleByBlockNumberAndIndex", params).asJsonObject.get("result").asJsonObject)
  }

// compilers omitted
// filter omitted
// logs omitted
// PoW omitted
// db-methods omitted (deprecated)
// shh-methods omitted
}
