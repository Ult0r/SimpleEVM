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

class Transaction {
  extension Utils u = new Utils

  @Accessors private EVMWord nonce
  @Accessors private EVMWord gasPrice
  @Accessors private EVMWord gasLimit
  @Accessors private EVMWord to // 160-bit address
  @Accessors private EVMWord value
  @Accessors private UnsignedByte v
  @Accessors private EVMWord r
  @Accessors private EVMWord s
  @Accessors private UnsignedByte[] data
  @Accessors private boolean isData // opposing to being init

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

    isData = !obj.get("to").jsonNull
    if(isData) {
      to = EVMWord.fromString(obj.get("to").asString)
    }

    data = obj.get("input").asString.fromHex.map[new UnsignedByte(it)]
  }
  
  def EVMWord hash() {
    //TODO
  }
  
  def EVMWord getSender() {
    //TODO
  }
}
