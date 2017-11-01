package org.itemis.evm.op

import org.itemis.evm.EVMOperation
import org.itemis.evm.EVMRuntime
import org.itemis.types.EVMWord
import org.itemis.evm.EVMOperation.FeeClass
import org.itemis.utils.StaticUtils

abstract class SHA3 {
  def static SHA3(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    
    var counter = new EVMWord(s0)
    val topBorder = s0.add(s1)
    
    val list = newArrayList
    while (counter.lessThan(topBorder)) {
      list.add(runtime.memory.get(counter))
      counter.inc
    }
    
    runtime.pushStackItem(StaticUtils.keccak256(list))
    runtime.memorySize = EVMRuntime.calcMemorySize(runtime.memorySize, s0, s1)
    
    val var_cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.SHA3WORD).mul(s1.divRoundUp(new EVMWord(32)))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.SHA3).add(var_cost))
  }
}