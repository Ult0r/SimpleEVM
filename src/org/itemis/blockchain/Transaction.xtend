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
import org.itemis.types.UnsignedByte
import com.google.gson.JsonObject
import org.itemis.utils.Utils
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.List
import org.itemis.evm.utils.EVMUtils
import org.itemis.types.Address
import org.itemis.types.Hash256

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
  //TODO: remove this when implementing Cipolla
  private Address sender //160-bit address

  new() {
  }

  new(JsonObject obj) {
    nonce = new EVMWord(obj.get("nonce").asString.fromHex.reverseView)
    gasPrice = new EVMWord(obj.get("gasPrice").asString.fromHex.reverseView)
    gasLimit = new EVMWord(obj.get("gas").asString.fromHex.reverseView)

    value = new EVMWord(obj.get("value").asString.fromHex.reverseView)

    v = fromHex(obj.get("v").asString).map[new UnsignedByte(it)].get(0)
    r = EVMWord.fromString(obj.get("r").asString)
    s = EVMWord.fromString(obj.get("s").asString)

    val isData = !obj.get("to").jsonNull
    if(isData) {
      to = Address.fromString(obj.get("to").asString)
    }

    data = obj.get("input").asString.fromHex.map[new UnsignedByte(it)]
    
    //TODO: remove this when implementing Cipolla
    sender = Address.fromString(obj.get("from").asString)
  }
  
  //TODO: Test
  def Hash256 hash() {
    val fields = fields
    val _fields = fields.take(5).toList
    _fields.add(fields.last)
    
    keccak256(rlp(_fields).map[byteValue])
  }
  
  //TODO: Test
  def List<UnsignedByte[]> getFields() {
    val List<UnsignedByte[]> fields = newArrayList
    fields.add(nonce.toUnsignedByteArray.reverseView.dropWhile[it == 0].toList)
    fields.add(gasPrice.toUnsignedByteArray.reverseView.dropWhile[it == 0].toList)
    fields.add(gasLimit.toUnsignedByteArray.reverseView.dropWhile[it == 0].toList)
    if (to !== null) {
      fields.add(to.toUnsignedByteArray.take(20))
    } else {
      fields.add(newArrayOfSize(0))
    }
    fields.add(value.toUnsignedByteArray.reverseView.dropWhile[it == 0].toList)
    val vArray = newArrayOfSize(1)
    vArray.set(0, v)
    fields.add(vArray)
    fields.add(r.toUnsignedByteArray.reverseView.dropWhile[it == 0].toList)
    fields.add(s.toUnsignedByteArray.reverseView.dropWhile[it == 0].toList)
    fields.add(data)
    
    fields
  }
  
  def Address getSender() {
    //TODO: use Cipolla to generate sender from v, r, s
    sender
  }
}
