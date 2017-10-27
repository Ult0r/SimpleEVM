package org.itemis.evm.op

import org.itemis.evm.EVMOperation
import org.itemis.evm.EVMRuntime
import org.itemis.evm.EVMOperation.FeeClass
import org.itemis.types.EVMWord
import org.itemis.blockchain.BlockchainData

abstract class BlockInformation {
  static class BLOCKHASH extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val diff = runtime.currentBlock.number.sub(s0)
      
      runtime.stack.push(
        if (diff.toUnsignedInt <= 256) {
          BlockchainData.getBlockHashByNumber(diff)
        } else {
          new EVMWord(0)
        }
      )
      
      Pair.of(FEE_SCHEDULE.get(FeeClass.BLOCKHASH), null)
    }
  }
}