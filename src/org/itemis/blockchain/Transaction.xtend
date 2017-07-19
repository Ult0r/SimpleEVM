package org.itemis.blockchain

import org.itemis.evm.types.EVMWord
import org.itemis.evm.types.UnsignedByte

class Transaction {
	private EVMWord nonce
	private EVMWord gasPrice
	private EVMWord gasLimit
	private EVMWord to //160-bit address
	private EVMWord value
	private UnsignedByte v
	private EVMWord r
	private EVMWord s
	
}