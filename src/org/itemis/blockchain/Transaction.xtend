package org.itemis.blockchain

import org.itemis.evm.types.EVMWord
import org.itemis.evm.types.UnsignedByte
import com.google.gson.JsonObject

class Transaction {
	private EVMWord nonce
	private EVMWord gasPrice
	private EVMWord gasLimit
	private EVMWord to //160-bit address
	private EVMWord value
	private UnsignedByte v
	private EVMWord r
	private EVMWord s
	private UnsignedByte[] data
	private boolean isData //opposing to being init
  
  new(JsonObject object) {
    nonce = EVMWord.fromString(obj.get("nonce").asString)
    transactionIndex = EVMWord.fromString(obj.get("transactionIndex").asString)
    blockHash = EVMWord.fromString(obj.get("blockHash").asString)
    blockNumber = EVMWord.fromString(obj.get("blockNumber").asString)
    cumulativeGasUsed = EVMWord.fromString(obj.get("cumulativeGasUsed").asString)
    gasUsed = EVMWord.fromString(obj.get("gasUsed").asString)
    contractAddress = EVMWord.fromString(obj.get("contractAddress").asString)
    
    //TODO
    throw new UnsupportedOperationException("TODO: auto-generated method stub")
  }
	
}