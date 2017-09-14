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

import com.google.gson.JsonObject
import org.itemis.types.EVMWord
import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.itemis.utils.Utils

class TransactionReceipt {
  extension Utils u = new Utils
  
  @Accessors EVMWord transactionHash
  @Accessors EVMWord transactionIndex
  @Accessors EVMWord blockHash
  @Accessors EVMWord blockNumber
  @Accessors EVMWord cumulativeGasUsed
  @Accessors EVMWord gasUsed

  @Accessors boolean isContractCreation
  @Accessors EVMWord contractAddress
  @Accessors List<JsonObject> logs

  new(JsonObject obj) {
    transactionHash = EVMWord.fromString(obj.get("transactionHash").asString)
    transactionIndex = new EVMWord(obj.get("transactionIndex").asString.fromHex, false)
    blockHash = EVMWord.fromString(obj.get("blockHash").asString)
    blockNumber = new EVMWord(obj.get("blockNumber").asString.fromHex, false)
    cumulativeGasUsed = new EVMWord(obj.get("cumulativeGasUsed").asString.fromHex, false)
    gasUsed = new EVMWord(obj.get("gasUsed").asString.fromHex, false)

    isContractCreation = !obj.get("contractAddress").jsonNull
    if(isContractCreation) {
      contractAddress = EVMWord.fromString(obj.get("contractAddress").asString)
    }

    logs = obj.get("logs").asJsonArray.toList.map[asJsonObject]
  }
}
