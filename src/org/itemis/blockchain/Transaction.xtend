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

class Transaction {
  extension Utils u = new Utils
  extension EVMUtils e = new EVMUtils

  @Accessors private EVMWord nonce
  @Accessors private EVMWord gasPrice
  @Accessors private EVMWord gasLimit
  @Accessors private Address to // 160-bit address
  @Accessors private EVMWord value
  @Accessors private UnsignedByte v
  @Accessors private EVMWord r
  @Accessors private EVMWord s
  @Accessors private UnsignedByte[] data
  // TODO: remove this when implementing Cipolla
  private Address sender // 160-bit address

  new() {
  }

  new(JsonObject obj) {
    nonce = new EVMWord(obj.get("nonce").asString.fromHex(true).reverseView)
    gasPrice = new EVMWord(obj.get("gasPrice").asString.fromHex(true).reverseView)
    gasLimit = new EVMWord(obj.get("gas").asString.fromHex(true).reverseView)

    value = new EVMWord(obj.get("value").asString.fromHex.reverseView)

    v = fromHex(obj.get("v").asString).map[new UnsignedByte(it)].get(0)
    r = EVMWord.fromString(obj.get("r").asString)
    s = EVMWord.fromString(obj.get("s").asString)

    val isData = !obj.get("to").jsonNull
    if(isData) {
      to = Address.fromString(obj.get("to").asString)
    }

    data = obj.get("input").asString.fromHex.map[new UnsignedByte(it)]

    // TODO: remove this when implementing Cipolla
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
    fields.add(r.trimTrailingZerosAndReverse.reverseView)
    fields.add(s.trimTrailingZerosAndReverse.reverseView)

    fields
  }

  def Address getSender() {
    // TODO: use Cipolla to generate sender from v, r, s
    sender
  }
}
