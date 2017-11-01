package org.itemis.evm.op;

import org.itemis.evm.EVMOperation;
import org.itemis.evm.EVMRuntime;
import org.itemis.types.EVMWord;
import org.itemis.evm.EVMOperation.FeeClass
import java.math.BigInteger

abstract class StopAndArithmeticOperations {
  private final static BigInteger MAX_VALUE = BigInteger.valueOf(2).pow(256)
  
  def static STOP(EVMRuntime runtime) {
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.ZERO))
  }
  
  def static ADD(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    runtime.pushStackItem(s0.add(s1))

    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static MUL(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    runtime.pushStackItem(s0.mul(s1))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.LOW))
  }

  def static SUB(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    runtime.pushStackItem(s0.sub(s1))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static DIV(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    if(s1.zero) {
      runtime.pushStackItem(s1)
    } else {
      runtime.pushStackItem(EVMWord.fromBigInteger(s0.toUnsignedBigInteger.divide(s1.toUnsignedBigInteger)))
    }
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.LOW))
  }

  def static SDIV(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    if(s1.zero) {
      runtime.pushStackItem(s1)
    } else if(s1.inc.zero && s0.toBigInteger.getLowestSetBit == 254 && s0.negative) {
      runtime.pushStackItem(s0)
    } else {
      runtime.pushStackItem(s0.div(s1))
    }
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.LOW))
  }

  def static MOD(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    if(s1.zero) {
      runtime.pushStackItem(s1)
    } else {
      runtime.pushStackItem(EVMWord.fromBigInteger(s0.toUnsignedBigInteger.mod(s1.toUnsignedBigInteger)))
    }
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.LOW))
  }

  def static SMOD(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    if(s1.zero) {
      runtime.pushStackItem(s1)
    } else {
      runtime.pushStackItem(EVMWord.fromBigInteger(s0.toBigInteger.mod(s1.toBigInteger)))
    }
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.LOW))
  }

  def static ADDMOD(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    val s2 = runtime.popStackItem

    if(s2.zero) {
      runtime.pushStackItem(s2)
    } else {
      runtime.pushStackItem(EVMWord.fromBigInteger(s0.toBigInteger.add(s1.toBigInteger).mod(s2.toBigInteger)))
    }
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.MID))
  }

  def static MULMOD(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    val s2 = runtime.popStackItem

    if(s2.zero) {
      runtime.pushStackItem(s2)
    } else {
      runtime.pushStackItem(EVMWord.fromBigInteger(s0.toBigInteger.multiply(s1.toBigInteger).mod(s2.toBigInteger)))
    }
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.MID))
  }

  def static EXP(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    if(s1.zero) {
      runtime.pushStackItem(new EVMWord(1))
      runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.EXP))
    } else {
      runtime.pushStackItem(EVMWord.fromBigInteger(s0.toBigInteger.modPow(s1.toBigInteger, MAX_VALUE)))
      val var_cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.EXP).mul(new EVMWord(1 + s1.log(new EVMWord(256))))
      runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.EXP).add(var_cost))
    }
  }

  def static SIGNEXTEND(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    val t = new EVMWord(256).sub(s0.inc.mul(new EVMWord(8))).getNthField(0)
    var result = s1.toBigInteger
    val bit_t = result.testBit(t.intValue)

    for (var i = 0; i < 256; i++) {
      if(i <= t.intValue) {
        if(bit_t) {
          result = result.setBit(i)
        } else {
          result = result.clearBit(i)
        }
      }
    }

    runtime.pushStackItem(EVMWord.fromBigInteger(result))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.LOW))
  }
}
