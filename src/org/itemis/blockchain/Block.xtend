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
import org.itemis.evm.utils.StaticEVMUtils
import org.itemis.utils.Utils
import org.itemis.evm.utils.EVMUtils
import org.itemis.types.UnsignedByte
import org.itemis.evm.utils.MerklePatriciaTrie
import java.math.BigInteger

class Block {
  extension Utils u = new Utils
  extension EVMUtils e = new EVMUtils
  
  @Accessors private EVMWord parentHash
  @Accessors private EVMWord ommersHash
  @Accessors private EVMWord beneficiary // only 160 bits used
  @Accessors private EVMWord stateRoot
  @Accessors private EVMWord transactionsRoot
  @Accessors private EVMWord receiptsRoot
  @Accessors private Int2048 logsBloom
  @Accessors private EVMWord difficulty
  @Accessors private EVMWord number
  @Accessors private EVMWord gasLimit
  @Accessors private EVMWord gasUsed
  @Accessors private EVMWord timestamp // seconds since The Epoch
  @Accessors private byte[] extraData
  @Accessors private EVMWord mixHash
  @Accessors private EVMWord nonce // 64-bit hash
  @Accessors private List<EVMWord> ommers
  @Accessors private List<Transaction> transactions

  def static Block getGenesisBlock() { //XXX: varies from the paper a lot
    val genesis = new Block()
    genesis.parentHash = EVMWord.ZERO
    genesis.ommersHash = StaticUtils.keccak256(StaticEVMUtils.rlp(newArrayList()).map[byteValue]) //0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347
    genesis.beneficiary = EVMWord.ZERO
		genesis.stateRoot = EVMWord.fromString("0xD7F8974FB5AC78D9AC099B9AD5018BEDC2CE0A72DAD1827A1709DA30580F0544")
    genesis.transactionsRoot = MerklePatriciaTrie.EMPTY_TRIE_HASH
    genesis.receiptsRoot = MerklePatriciaTrie.EMPTY_TRIE_HASH
    genesis.logsBloom = new Int2048(0)
    genesis.difficulty = EVMWord.fromBigInteger(new BigInteger("400000000", 16))
    genesis.number = EVMWord.ZERO
    genesis.gasLimit = EVMWord.fromString("0x8813")
    genesis.gasUsed = EVMWord.ZERO
    genesis.timestamp = new EVMWord(1438269973) // Jul-30-2015 15:26:13 UTC //XXX: paper specifies 0 here
    genesis.extraData = StaticUtils.fromHex("0x11bbe8db4e347b4e8c937c1c8370e4b5ed33adb3db69cbdb7a38e1e50b1b82fa")
    genesis.mixHash = EVMWord.ZERO
    genesis.nonce = EVMWord.fromString("0x0000000000000042") //66 dec
    genesis.ommers = newArrayList
    genesis.transactions = newArrayList
    genesis
  }

  new() {
  }

  new(JsonObject obj) {
    parentHash = EVMWord.fromString(obj.get("parentHash").asString)
    ommersHash = EVMWord.fromString(obj.get("sha3Uncles").asString)
    beneficiary = EVMWord.fromString(obj.get("miner").asString)
    stateRoot = EVMWord.fromString(obj.get("stateRoot").asString)
    transactionsRoot = EVMWord.fromString(obj.get("transactionsRoot").asString)
    receiptsRoot = EVMWord.fromString(obj.get("receiptsRoot").asString)
    logsBloom = Int2048.fromString(obj.get("logsBloom").asString)
    difficulty = new EVMWord(fromHex(obj.get("difficulty").asString).reverseView)
    number = EVMWord.fromString(obj.get("number").asString)
    gasLimit = new EVMWord(fromHex(obj.get("gasLimit").asString).reverseView)
    gasUsed = EVMWord.fromString(obj.get("gasUsed").asString) //XXX: reverse?
    timestamp = new EVMWord(fromHex(obj.get("timestamp").asString).reverseView)
    extraData = fromHex(obj.get("extraData").asString)
    mixHash = EVMWord.fromString(obj.get("mixHash").asString)
    nonce = EVMWord.fromString(obj.get("nonce").asString)

    ommers = obj.get("uncles").asJsonArray.toList.map[asString].map[EVMWord.fromString(it)]

    // might be uncle
    if(obj.has("transactions")) {
      transactions = obj.get("transactions").asJsonArray.toList.map[asJsonObject].map[new Transaction(it)]
    }
  }
  
  def EVMWord hash() {
    keccak256(rlp(fields).map[byteValue])
  }
  
  def List<UnsignedByte[]> getFields() {
    val List<UnsignedByte[]> fields = newArrayList
    fields.add(parentHash.toByteArray.map[new UnsignedByte(it)])
    fields.add(ommersHash.toByteArray.map[new UnsignedByte(it)])
    fields.add(beneficiary.toByteArray.take(20).map[new UnsignedByte(it)])
    fields.add(stateRoot.toByteArray.map[new UnsignedByte(it)])
    fields.add(transactionsRoot.toByteArray.map[new UnsignedByte(it)])
    fields.add(receiptsRoot.toByteArray.map[new UnsignedByte(it)])
    fields.add(logsBloom.toByteArray.map[new UnsignedByte(it)])
    fields.add(difficulty.toByteArray.reverseView.dropWhile[it == 0].toList.map[new UnsignedByte(it)])
    fields.add(number.toByteArray.reverseView.dropWhile[it == 0].toList.map[new UnsignedByte(it)])
    fields.add(gasLimit.toByteArray.reverseView.dropWhile[it == 0].toList.map[new UnsignedByte(it)])
    fields.add(gasUsed.toByteArray.reverseView.dropWhile[it == 0].toList.map[new UnsignedByte(it)])
    fields.add(timestamp.toByteArray.reverseView.dropWhile[it == 0].toList.map[new UnsignedByte(it)])
    fields.add(extraData.map[new UnsignedByte(it)])
    fields.add(mixHash.toByteArray.map[new UnsignedByte(it)])
    fields.add(nonce.toByteArray.take(8).toList.map[new UnsignedByte(it)])
    
    fields
  }
  
  def UnsignedByte[] headerRLP() {
    rlp(fields.take(13).toList)
  }
  
  def EVMWord headerRLPHash() {
    keccak256(headerRLP.map[byteValue])
  }
  
}
