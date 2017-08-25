package org.itemis.blockchain

import org.itemis.types.EVMWord
import org.itemis.types.UnsignedByte
import com.google.gson.JsonObject
import org.itemis.utils.Utils
import org.eclipse.xtend.lib.annotations.Accessors

class Transaction {
  extension Utils u = new Utils
  
	@Accessors private EVMWord nonce
	@Accessors private EVMWord gasPrice
	@Accessors private EVMWord gasLimit
	@Accessors private EVMWord to //160-bit address
	@Accessors private EVMWord value
	@Accessors private UnsignedByte v
	@Accessors private EVMWord r
	@Accessors private EVMWord s
	@Accessors private UnsignedByte[] data
	@Accessors private boolean isData //opposing to being init
  
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
  
  //TODO: calculate hash
  
}