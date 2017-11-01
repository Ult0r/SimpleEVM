package org.itemis.evm.op

import org.itemis.evm.EVMOperation
import org.itemis.evm.EVMRuntime
import org.itemis.evm.EVMOperation.FeeClass
import org.itemis.types.EVMWord
import org.itemis.blockchain.BlockchainData

abstract class BlockInformation {
  def static BLOCKHASH(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val diff = runtime.currentBlock.number.sub(s0)

    runtime.pushStackItem(
      if(diff.toUnsignedInt <= 256) {
        BlockchainData.getBlockHashByNumber(s0)
      } else {
        new EVMWord(0)
      }
    )

    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BLOCKHASH))
  }

  def static COINBASE(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.currentBlock.beneficiary)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BALANCE))
  }

  def static TIMESTAMP(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.currentBlock.timestamp)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE))
  }

  def static NUMBER(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.currentBlock.number)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE))
  }

  def static DIFFICULTY(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.currentBlock.difficulty)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE))
  }

  def static GASLIMIT(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.currentBlock.gasLimit)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE))
  }
}
