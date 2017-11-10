package org.itemis.evm.op

import org.itemis.evm.EVMRuntime
import org.itemis.evm.EVMLog
import org.itemis.evm.EVMOperation
import org.itemis.evm.EVMOperation.FeeClass

abstract class LoggingOperations {
  def static LOGN(int n, EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    
    val data = newByteArrayOfSize(s1.unsignedIntValue.intValue)
    for (var i = 0; i < s1.unsignedIntValue.intValue; i++) {
      data.set(i, runtime.memory.get(s0.add(i)))
    }
    
    runtime.logs.add(
      switch n {
        case 0: new EVMLog(runtime.codeAddress, data)
        case 1: {
          val s2 = runtime.popStackItem
          new EVMLog(runtime.codeAddress, s2, data)
        }
        case 2: {
          val s2 = runtime.popStackItem
          val s3 = runtime.popStackItem
          new EVMLog(runtime.codeAddress, s2, s3, data)
        }
        case 3: {
          val s2 = runtime.popStackItem
          val s3 = runtime.popStackItem
          val s4 = runtime.popStackItem
          new EVMLog(runtime.codeAddress, s2, s3, s4, data)
        }
        case 4: {
          val s2 = runtime.popStackItem
          val s3 = runtime.popStackItem
          val s4 = runtime.popStackItem
          val s5 = runtime.popStackItem
          new EVMLog(runtime.codeAddress, s2, s3, s4, s5, data)
        }
      }
    )
    
    runtime.memorySize = EVMRuntime.calcMemorySize(runtime.memorySize, s0, s1)
    var cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.LOG)
    cost = cost.add(EVMOperation.FEE_SCHEDULE.get(FeeClass.LOGDATA).mul(s1))
    cost = cost.add(EVMOperation.FEE_SCHEDULE.get(FeeClass.LOGTOPIC).mul(n))
    runtime.addGasCost(cost)
  }
}