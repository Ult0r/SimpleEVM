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
  
  new(JsonObject object) {
    //TODO
    throw new UnsupportedOperationException("TODO: auto-generated method stub")
  }
	
}