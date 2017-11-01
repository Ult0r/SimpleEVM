package org.itemis.evm.op

import org.itemis.evm.EVMRuntime
import org.itemis.evm.EVMOperation
import org.itemis.evm.EVMOperation.FeeClass

abstract class DuplicationOperations {
  def static DUPN(int n, EVMRuntime runtime) {
    
    runtime.pushStackItem(runtime.getStackItem(n - 1))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }
}