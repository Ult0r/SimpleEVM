package org.itemis.blockchain

import org.itemis.evm.types.EVMWord
import org.itemis.evm.types.UnsignedByte
import com.google.gson.JsonObject
import org.itemis.evm.utils.Utils

class Transaction {
  extension Utils u = new Utils
  
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
  
  new(JsonObject obj) {
    nonce = EVMWord.fromString(obj.get("nonce").asString)
    gasPrice = EVMWord.fromString(obj.get("gasPrice").asString)
    gasLimit = EVMWord.fromString(obj.get("gas").asString)
    
    value = EVMWord.fromString(obj.get("value").asString)
    
    v = fromHex(obj.get("v").asString).map[new UnsignedByte(it)].get(0)
    r = EVMWord.fromString(obj.get("r").asString)
    s = EVMWord.fromString(obj.get("s").asString)
    
    isData = !obj.get("to").jsonNull
    if (isData) {
      to = EVMWord.fromString(obj.get("to").asString)
    }
    
    data = obj.get("input").asString.fromHex.map[new UnsignedByte(it)]
  }
}