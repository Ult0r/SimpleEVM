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

import org.itemis.evm.types.EVMWord
import org.itemis.evm.types.Int2048
import org.itemis.evm.utils.StaticUtils
import java.util.List

class Block {
	private EVMWord parentHash
	private EVMWord ommersHash
	private EVMWord beneficiary // only 160 bits used
	private EVMWord stateRoot
	private EVMWord transactionsRoot
	private EVMWord receiptsRoot
	private Int2048 logsBloom
	private EVMWord difficulty
	private EVMWord number
	private EVMWord gasUsed
	private EVMWord gasLimit
	private EVMWord timestamp // second since The Epoch
	private EVMWord extraData
	private EVMWord mixHash
	private EVMWord nonce // 64-bit hash
	private List<EVMWord> ommers
//	private List<Transaction> transactions //TODO: implement blockchain.Transaction
	
	private static Block GENESIS_BLOCK = null
	
	def static Block getGenesisBlock() {
		if (GENESIS_BLOCK === null) {
			GENESIS_BLOCK = new Block()
			GENESIS_BLOCK.parentHash = new EVMWord(0)
			GENESIS_BLOCK.ommersHash = StaticUtils.sha3_256(StaticUtils.rlp(newArrayList()).map[byteValue])
			GENESIS_BLOCK.beneficiary = new EVMWord(0)
//			GENESIS_BLOCK.stateRoot = new EVMWord(0xDEADBEEF) //TODO: get actual value
			GENESIS_BLOCK.transactionsRoot = new EVMWord(0)
			GENESIS_BLOCK.receiptsRoot = new EVMWord(0)
			GENESIS_BLOCK.logsBloom = new Int2048(0)
			GENESIS_BLOCK.difficulty = new EVMWord(131072) //2^17
			GENESIS_BLOCK.number = new EVMWord(0)
			GENESIS_BLOCK.gasUsed = new EVMWord(0)
			GENESIS_BLOCK.gasLimit = new EVMWord(3141592)
//			GENESIS_BLOCK.timestamp = new EVMWord(0) //TODO: get actual value
			GENESIS_BLOCK.extraData = new EVMWord(0)
			GENESIS_BLOCK.mixHash = new EVMWord(0)
			GENESIS_BLOCK.nonce = StaticUtils.sha3_256(#[42 as byte])
			GENESIS_BLOCK.ommers = newArrayList
//			GENESIS_BLOCK.transactions = newArrayList //TODO: valid after implementing blockchain.Transaction
		}
		GENESIS_BLOCK
	}
