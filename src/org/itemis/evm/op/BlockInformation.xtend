/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.evm.op

import org.itemis.evm.EVMRuntime
import org.itemis.evm.EVMOperation.FeeClass
import org.itemis.types.impl.EVMWord
import org.itemis.blockchain.BlockchainData

abstract class BlockInformation {
  def static BLOCKHASH(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val diff = runtime.currentBlock.number.sub(s0)

    runtime.pushStackItem(
      if(diff.unsignedIntValue <= 256) {
        BlockchainData.getBlockHashByNumber(s0).toEVMWord
      } else {
        EVMWord.ZERO
      }
    )

    runtime.addGasCost(FeeClass.BLOCKHASH)
  }

  def static COINBASE(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.currentBlock.beneficiary.toEVMWord)
    runtime.addGasCost(FeeClass.BALANCE)
  }

  def static TIMESTAMP(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.currentBlock.timestamp)
    runtime.addGasCost(FeeClass.BASE)
  }

  def static NUMBER(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.currentBlock.number)
    runtime.addGasCost(FeeClass.BASE)
  }

  def static DIFFICULTY(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.currentBlock.difficulty)
    runtime.addGasCost(FeeClass.BASE)
  }

  def static GASLIMIT(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.currentBlock.gasLimit)
    runtime.addGasCost(FeeClass.BASE)
  }
}
