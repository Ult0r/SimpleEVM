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

import org.itemis.types.impl.EVMWord
import org.itemis.types.UnsignedByte
import com.google.gson.JsonObject
import org.itemis.utils.Utils
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.List
import org.itemis.evm.utils.EVMUtils
import org.itemis.types.impl.Address
import org.itemis.types.impl.Hash256
import java.math.BigInteger
import org.itemis.utils.StaticUtils

class Transaction {
  extension Utils u = new Utils
  extension EVMUtils e = new EVMUtils

  @Accessors private EVMWord nonce
  @Accessors private EVMWord gasPrice
  @Accessors private EVMWord gasLimit
  @Accessors private Address to // 160-bit address
  @Accessors private EVMWord value
  @Accessors private UnsignedByte v
  @Accessors private BigInteger r
  @Accessors private BigInteger s
  @Accessors private UnsignedByte[] data
  @Accessors private Address sender //TODO: fix cipolla

  new() {
  }

  new(JsonObject obj) {
    nonce = new EVMWord(obj.get("nonce").asString.fromHex(true).reverseView)
    gasPrice = new EVMWord(obj.get("gasPrice").asString.fromHex(true).reverseView)
    gasLimit = new EVMWord(obj.get("gas").asString.fromHex(true).reverseView)

    value = new EVMWord(obj.get("value").asString.fromHex(true).reverseView)

    v = fromHex(obj.get("v").asString).map[new UnsignedByte(it)].get(0)
    r = new BigInteger(StaticUtils.fromHex(obj.get("r").asString, true))
    s = new BigInteger(StaticUtils.fromHex(obj.get("s").asString, true))

    val isData = !obj.get("to").jsonNull
    if(isData) {
      to = Address.fromString(obj.get("to").asString)
    }

    data = obj.get("input").asString.fromHex.map[new UnsignedByte(it)]
    sender = Address.fromString(obj.get("from").asString)
  }
  
  def Hash256 messageHash() {
    keccak256(rlp(fields.take(6).toList).map[byteValue])
  }

  def Hash256 hash() {
    keccak256(rlp(fields).map[byteValue])
  }

  def List<UnsignedByte[]> getFields() {
    val List<UnsignedByte[]> fields = newArrayList
    fields.add(nonce.trimTrailingZerosAndReverse)
    fields.add(gasPrice.trimTrailingZerosAndReverse)
    fields.add(gasLimit.trimTrailingZerosAndReverse)
    if(to !== null) {
      fields.add(to.toUnsignedByteArray)
    } else {
      fields.add(newArrayOfSize(0))
    }
    fields.add(value.trimTrailingZerosAndReverse)
    fields.add(data)
    
    val vArray = newArrayOfSize(1)
    vArray.set(0, v)
    fields.add(vArray)
    fields.add(r.toByteArray.map[new UnsignedByte(it)])
    fields.add(s.toByteArray.map[new UnsignedByte(it)])

    fields
  }

  def Address getSender() {
    sender

//TODO: fix cipolla
//    val recId = switch (v.intValue) {
//      case 0x1b: 0
//      case 0x1c: 1
//      case 0x25: 0 //XXX: not sure why this changed somewhere between blocks 2,500,000 and 3,000,000
//      case 0x26: 1 //XXX: not sure why this changed somewhere between blocks 2,500,000 and 3,000,000
//    }
//    val pubKey = ECDSARecover(recId, s, r, messageHash)
//    new Address(StaticUtils.keccak256(pubKey.subList(1, pubKey.length)).toByteArray.drop(12))
  }
}
