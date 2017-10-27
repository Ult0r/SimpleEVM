package org.itemis.evm.op;

import org.itemis.evm.EVMOperation;
import org.itemis.evm.EVMRuntime;
import org.itemis.types.EVMWord;
import java.math.BigInteger

abstract class ArithmeticOperations {
  static class ADD extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      runtime.stack.push(s0.add(s1))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW), null)
    }
  }
  
  static class MUL extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      runtime.stack.push(s0.mul(s1))
      Pair.of(FEE_SCHEDULE.get(FeeClass.LOW), null)
    }
  }
  
  static class SUB extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      runtime.stack.push(s0.sub(s1))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW), null)
    }
  }
  
  static class DIV extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      if (s1.zero) {
        runtime.stack.push(s1)
      } else {
        runtime.stack.push(EVMWord.fromBigInteger(s0.toUnsignedBigInteger.divide(s1.toUnsignedBigInteger)))
      }
      Pair.of(FEE_SCHEDULE.get(FeeClass.LOW), null)
    }
  }
  
  static class SDIV extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      if (s1.zero) {
        runtime.stack.push(s1)
      } else if (s1.inc.zero && s0.toBigInteger.getLowestSetBit == 254 && s0.negative) {
        runtime.stack.push(s0)
      } else {
        runtime.stack.push(s0.div(s1))
      }
      Pair.of(FEE_SCHEDULE.get(FeeClass.LOW), null)
    }
  }
  
  static class MOD extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      if (s1.zero) {
        runtime.stack.push(s1)
      } else {
        runtime.stack.push(EVMWord.fromBigInteger(s0.toUnsignedBigInteger.mod(s1.toUnsignedBigInteger)))
      }
      Pair.of(FEE_SCHEDULE.get(FeeClass.LOW), null)
    }
  }
  
  static class SMOD extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      if (s1.zero) {
        runtime.stack.push(s1)
      } else {
        runtime.stack.push(EVMWord.fromBigInteger(s0.toBigInteger.mod(s1.toBigInteger)))
      }
      Pair.of(FEE_SCHEDULE.get(FeeClass.LOW), null)
    }
  }
  
  static class ADDMOD extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      val s2 = runtime.stack.pop
      
      if (s2.zero) {
        runtime.stack.push(s2)
      } else {
        runtime.stack.push(EVMWord.fromBigInteger(s0.toBigInteger.add(s1.toBigInteger).mod(s2.toBigInteger)))
      }
      Pair.of(FEE_SCHEDULE.get(FeeClass.MID), null)
    }
  }
  
  static class MULMOD extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      val s2 = runtime.stack.pop
      
      if (s2.zero) {
        runtime.stack.push(s2)
      } else {
        runtime.stack.push(EVMWord.fromBigInteger(s0.toBigInteger.multiply(s1.toBigInteger).mod(s2.toBigInteger)))
      }
      Pair.of(FEE_SCHEDULE.get(FeeClass.MID), null)
    }
  }
  
  static class EXP extends EVMOperation {
    private final static BigInteger MAX_VALUE = BigInteger.valueOf(2).pow(255)
    
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      
      if (s1.zero) {
        runtime.stack.push(new EVMWord(1))
        Pair.of(FEE_SCHEDULE.get(FeeClass.EXP), null)
      } else {
        runtime.stack.push(EVMWord.fromBigInteger(s0.toBigInteger.modPow(s1.toBigInteger, MAX_VALUE)))
        val var_cost = FEE_SCHEDULE.get(FeeClass.EXP).mul(new EVMWord(1 + s1.log(new EVMWord(256))))
        Pair.of(FEE_SCHEDULE.get(FeeClass.EXP).add(var_cost), null)
      }
    }
  }
  
  static class SIGNEXTEND extends EVMOperation {
  override execute(EVMRuntime runtime) {
    val s0 = runtime.stack.pop
    val s1 = runtime.stack.pop
    
    val t = new EVMWord(256).sub(s0.inc.mul(new EVMWord(8))).getNthField(0)
    var result = s1.toBigInteger
    val bit_t = result.testBit(t.intValue)
    
    for (var i = 0; i < 256; i++) {
      if (i <= t.intValue) {
        if (bit_t) {
          result = result.setBit(i)
        } else {
          result = result.clearBit(i)
        }
      }
    }
    
    runtime.stack.push(EVMWord.fromBigInteger(result))
    Pair.of(FEE_SCHEDULE.get(FeeClass.LOW), null)
  }
}
}
