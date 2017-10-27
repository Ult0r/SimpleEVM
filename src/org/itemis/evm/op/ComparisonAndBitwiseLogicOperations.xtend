package org.itemis.evm.op

import org.itemis.evm.EVMOperation
import org.itemis.evm.EVMRuntime
import org.itemis.types.EVMWord

abstract class ComparisonAndBitwiseLogicOperations {
  static class EQ extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      
      runtime.stack.push(if (s0.equals(s1)) new EVMWord(1) else new EVMWord(0))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW), null)
    }
  }
  
  static class GT extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      
      runtime.stack.push(if (s1.toUnsignedBigInteger.subtract(s0.toUnsignedBigInteger).signum == -1) new EVMWord(1) else new EVMWord(0))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW), null)
    }
  }
  
  static class LT extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      
      runtime.stack.push(if (s0.toUnsignedBigInteger.subtract(s1.toUnsignedBigInteger).signum == -1) new EVMWord(1) else new EVMWord(0))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW), null)
    }
  }
  
  static class SGT extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      
      runtime.stack.push(if (s0.greaterThan(s1)) new EVMWord(1) else new EVMWord(0))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW), null)
    }
  }
  
  static class SLT extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      
      runtime.stack.push(if (s0.lessThan(s1)) new EVMWord(1) else new EVMWord(0))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW), null)
    }
  }
  
  static class ISZERO extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      
      runtime.stack.push(if (s0.zero) new EVMWord(1) else new EVMWord(0))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW), null)
    }
  }
  
  static class AND extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      
      runtime.stack.push(EVMWord.fromBigInteger(s0.toBigInteger.and(s1.toBigInteger)))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW), null)
    }
  }
  
  static class OR extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      
      runtime.stack.push(EVMWord.fromBigInteger(s0.toBigInteger.or(s1.toBigInteger)))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW), null)
    }
  }
  
  static class XOR extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      
      runtime.stack.push(EVMWord.fromBigInteger(s0.toBigInteger.xor(s1.toBigInteger)))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW), null)
    }
  }
  
  static class NOT extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      
      runtime.stack.push(EVMWord.fromBigInteger(s0.toBigInteger.not))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW), null)
    }
  }
  
  static class BYTE extends EVMOperation {
  override execute(EVMRuntime runtime) {
    val s0 = runtime.stack.pop
    val s1 = runtime.stack.pop
    
    if (s0.lessThan(new EVMWord(32))) {
      runtime.stack.push(new EVMWord(s1.getNthField(31 - s0.getNthField(0).intValue).intValue))      
    } else {
      runtime.stack.push(new EVMWord(0))
    }
    Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW), null)
  }
}
}