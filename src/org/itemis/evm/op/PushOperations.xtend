package org.itemis.evm.op

import org.itemis.evm.EVMRuntime
import org.itemis.types.EVMWord
import org.itemis.evm.EVMOperation
import org.itemis.evm.EVMOperation.FeeClass

abstract class PushOperations {
  def static PUSHN(int n, EVMRuntime runtime) {
    var bytes = newByteArrayOfSize(32)
    
    for (var i = 0; i < 32; i++) {
      bytes.set(i, if (i < n) {
        runtime.code.get(runtime.pc + i).value.byteValue
      } else {
        0 as byte
      })
    }
    
    runtime.pushStackItem(new EVMWord(bytes))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }
}