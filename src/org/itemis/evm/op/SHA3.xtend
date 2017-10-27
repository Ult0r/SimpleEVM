package org.itemis.evm.op

import org.itemis.evm.EVMOperation
import org.itemis.evm.EVMRuntime
import org.itemis.types.EVMWord
import org.itemis.utils.Utils

final class SHA3 extends EVMOperation {
  extension Utils e = new Utils 
  
  override execute(EVMRuntime runtime) {
    val s0 = runtime.stack.pop
    val s1 = runtime.stack.pop
    
    var counter = new EVMWord(s0)
    val topBorder = s0.add(s1)
    
    val list = newArrayList
    while (counter.lessThan(topBorder)) {
      list.add(runtime.memory.get(counter))
      counter.inc
    }
    
    runtime.stack.push(keccak256(list))
    runtime.memorySize = EVMRuntime.calcMemorySize(runtime.memorySize, s0, s1)
    
    val var_cost = FEE_SCHEDULE.get(FeeClass.SHA3WORD).mul(s1.divRoundUp(new EVMWord(32)))
    Pair.of(FEE_SCHEDULE.get(FeeClass.SHA3).add(var_cost), null)
  }
}