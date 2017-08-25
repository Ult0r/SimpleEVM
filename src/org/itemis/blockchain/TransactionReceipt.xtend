package org.itemis.blockchain

import com.google.gson.JsonObject
import org.itemis.types.EVMWord
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

class TransactionReceipt {
  @Accessors EVMWord transactionHash
  @Accessors EVMWord transactionIndex
  @Accessors EVMWord blockHash
  @Accessors EVMWord blockNumber
  @Accessors EVMWord cumulativeGasUsed
  @Accessors EVMWord gasUsed
  
  @Accessors boolean isContractCreation
  @Accessors EVMWord contractAddress
  @Accessors List<JsonObject> logs
  
  new(JsonObject obj) {
    transactionHash = EVMWord.fromString(obj.get("transactionHash").asString)
    transactionIndex = EVMWord.fromString(obj.get("transactionIndex").asString)
    blockHash = EVMWord.fromString(obj.get("blockHash").asString)
    blockNumber = EVMWord.fromString(obj.get("blockNumber").asString)
    cumulativeGasUsed = EVMWord.fromString(obj.get("cumulativeGasUsed").asString)
    gasUsed = EVMWord.fromString(obj.get("gasUsed").asString)
    
    isContractCreation = !obj.get("contractAddress").jsonNull
    if (isContractCreation) {
      contractAddress = EVMWord.fromString(obj.get("contractAddress").asString)
    }
    
    logs = obj.get("logs").asJsonArray.toList.map[asJsonObject]
  }
}
