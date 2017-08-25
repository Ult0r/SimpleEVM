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

import org.itemis.types.EVMWord
import org.itemis.types.Int2048
import org.itemis.utils.StaticUtils
import java.util.List
import com.google.gson.JsonObject
import org.eclipse.xtend.lib.annotations.Accessors

class Block {
	@Accessors private EVMWord parentHash
	@Accessors private EVMWord ommersHash
	@Accessors private EVMWord beneficiary // only 160 bits used
	@Accessors private EVMWord stateRoot
	@Accessors private EVMWord transactionsRoot
	@Accessors private EVMWord receiptsRoot
	@Accessors private Int2048 logsBloom
	@Accessors private EVMWord difficulty
	@Accessors private EVMWord number
	@Accessors private EVMWord gasUsed
	@Accessors private EVMWord gasLimit
	@Accessors private EVMWord timestamp // seconds since The Epoch
	@Accessors private EVMWord extraData
	@Accessors private EVMWord mixHash
	@Accessors private EVMWord nonce // 64-bit hash
	@Accessors private List<EVMWord> ommers
	@Accessors private List<Transaction> transactions
	
	private static Block GENESIS_BLOCK = null
	
	def static Block getGenesisBlock() {
		if (GENESIS_BLOCK === null) {
			GENESIS_BLOCK = new Block()
			GENESIS_BLOCK.parentHash = new EVMWord(0)
			GENESIS_BLOCK.ommersHash = StaticUtils.keccak256(StaticUtils.rlp(newArrayList()).map[byteValue])
			GENESIS_BLOCK.beneficiary = new EVMWord(0)
//			GENESIS_BLOCK.stateRoot = new EVMWord(0xDEADBEEF) //TODO: get actual value
			GENESIS_BLOCK.transactionsRoot = new EVMWord(0)
			GENESIS_BLOCK.receiptsRoot = new EVMWord(0)
			GENESIS_BLOCK.logsBloom = new Int2048(0)
			GENESIS_BLOCK.difficulty = new EVMWord(289824)
			GENESIS_BLOCK.number = new EVMWord(0)
			GENESIS_BLOCK.gasUsed = new EVMWord(0)
			GENESIS_BLOCK.gasLimit = new EVMWord(327680000)
			GENESIS_BLOCK.timestamp = new EVMWord(1438269973) //Jul-30-2015 15:26:13 UTC
			GENESIS_BLOCK.extraData = new EVMWord(0)
			GENESIS_BLOCK.mixHash = new EVMWord(0)
			GENESIS_BLOCK.nonce = StaticUtils.keccak256(#[42 as byte])
			GENESIS_BLOCK.ommers = newArrayList
			GENESIS_BLOCK.transactions = newArrayList
		}
		GENESIS_BLOCK
	}
	
	new() {
	  
	}
	
	new(JsonObject obj) {
    number = EVMWord.fromString(obj.get("number").asString)
    parentHash = EVMWord.fromString(obj.get("parentHash").asString)
    nonce = EVMWord.fromString(obj.get("nonce").asString)
    ommersHash = EVMWord.fromString(obj.get("sha3Uncles").asString)
    logsBloom = Int2048.fromString(obj.get("logsBloom").asString)
    transactionsRoot = EVMWord.fromString(obj.get("transactionsRoot").asString)
    stateRoot = EVMWord.fromString(obj.get("stateRoot").asString)
    receiptsRoot = EVMWord.fromString(obj.get("receiptsRoot").asString)
    beneficiary = EVMWord.fromString(obj.get("miner").asString)
    difficulty = EVMWord.fromString(obj.get("difficulty").asString)
    extraData = EVMWord.fromString(obj.get("extraData").asString)
    gasLimit = EVMWord.fromString(obj.get("gasLimit").asString)
    gasUsed = EVMWord.fromString(obj.get("gasUsed").asString)
    timestamp = EVMWord.fromString(obj.get("timestamp").asString)
    
    ommers = obj.get("uncles").asJsonArray.toList.map[asString].map[EVMWord.fromString(it)]
    
    //might be uncle
    if (obj.has("transactions")) {
      transactions = obj.get("transactions").asJsonArray.toList.map[asJsonObject].map[new Transaction(it)]
    }
	}
	
  //TODO: calculate hash
}
