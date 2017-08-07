package org.itemis.blockchain

import com.google.gson.JsonObject
import org.itemis.evm.types.EVMWord
import java.util.List

class TransactionReceipt {
  EVMWord transactionHash
  EVMWord transactionIndex
  EVMWord blockHash
  EVMWord blockNumber
  EVMWord cumulativeGasUsed
  EVMWord gasUsed
  EVMWord contractAddress
  List<JsonObject> logs
  
  new(JsonObject obj) {
    transactionHash = EVMWord.fromString(obj.get("transactionHash").asString)
    transactionIndex = EVMWord.fromString(obj.get("transactionIndex").asString)
    blockHash = EVMWord.fromString(obj.get("blockHash").asString)
    blockNumber = EVMWord.fromString(obj.get("blockNumber").asString)
    cumulativeGasUsed = EVMWord.fromString(obj.get("cumulativeGasUsed").asString)
    gasUsed = EVMWord.fromString(obj.get("gasUsed").asString)
    contractAddress = EVMWord.fromString(obj.get("contractAddress").asString)
    
    logs = obj.get("logs").asJsonArray.toList.map[asJsonObject]
  }
  
}
