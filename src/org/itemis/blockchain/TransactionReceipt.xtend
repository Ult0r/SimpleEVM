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
import org.itemis.types.Hash256
import org.itemis.types.Address

class TransactionReceipt {
  extension Utils u = new Utils

  @Accessors Hash256 transactionHash
  @Accessors EVMWord transactionIndex
  @Accessors Hash256 blockHash
  @Accessors EVMWord blockNumber
  @Accessors EVMWord cumulativeGasUsed
  @Accessors EVMWord gasUsed

  @Accessors boolean isContractCreation
  @Accessors Address contractAddress
  @Accessors List<JsonObject> logs

  new(JsonObject obj) {
    transactionHash = Hash256.fromString(obj.get("transactionHash").asString)
    transactionIndex = new EVMWord(obj.get("transactionIndex").asString.fromHex.reverseView)
    blockHash = Hash256.fromString(obj.get("blockHash").asString)
    blockNumber = new EVMWord(obj.get("blockNumber").asString.fromHex.reverseView)
    cumulativeGasUsed = new EVMWord(obj.get("cumulativeGasUsed").asString.fromHex.reverseView)
    gasUsed = new EVMWord(obj.get("gasUsed").asString.fromHex.reverseView)

    isContractCreation = !obj.get("contractAddress").jsonNull
    if(isContractCreation) {
      contractAddress = Address.fromString(obj.get("contractAddress").asString)
    }

    logs = obj.get("logs").asJsonArray.toList.map[asJsonObject]
  }
}
