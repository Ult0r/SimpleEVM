/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.evm.op;

import org.itemis.evm.EVMOperation;
import org.itemis.evm.EVMRuntime;
import org.itemis.types.impl.EVMWord;
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

    runtime.addGasCost(FeeClass.VERYLOW)
  }

  def static MUL(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    runtime.pushStackItem(s0.mul(s1))
    runtime.addGasCost(FeeClass.LOW)
  }

  def static SUB(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    runtime.pushStackItem(s0.sub(s1))
    runtime.addGasCost(FeeClass.VERYLOW)
  }

  def static DIV(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    if(s1.zero) {
      runtime.pushStackItem(s1)
    } else {
      runtime.pushStackItem(EVMWord.fromBigInteger(s0.toUnsignedBigInteger.divide(s1.toUnsignedBigInteger)))
    }
    runtime.addGasCost(FeeClass.LOW)
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
    runtime.addGasCost(FeeClass.LOW)
  }

  def static MOD(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    if(s1.zero) {
      runtime.pushStackItem(s1)
    } else {
      runtime.pushStackItem(EVMWord.fromBigInteger(s0.toUnsignedBigInteger.mod(s1.toUnsignedBigInteger)))
    }
    runtime.addGasCost(FeeClass.LOW)
  }

  def static SMOD(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    if(s1.zero) {
      runtime.pushStackItem(s1)
    } else {
      runtime.pushStackItem(EVMWord.fromBigInteger(s0.toBigInteger.mod(s1.toBigInteger)))
    }
    runtime.addGasCost(FeeClass.LOW)
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
    runtime.addGasCost(FeeClass.MID)
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
    runtime.addGasCost(FeeClass.MID)
  }

  def static EXP(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    if(s1.zero) {
      runtime.pushStackItem(EVMWord.ONE)
      runtime.addGasCost(FeeClass.EXP)
    } else {
      runtime.pushStackItem(EVMWord.fromBigInteger(s0.toBigInteger.modPow(s1.toBigInteger, MAX_VALUE)))
      val var_cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.EXP).mul(1 + s1.log(256))
      runtime.addGasCost(FeeClass.EXP)
      runtime.addGasCost(var_cost)
    }
  }

  def static SIGNEXTEND(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    val t = new EVMWord(256).sub(s0.inc.mul(8)).get(0)
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
    runtime.addGasCost(FeeClass.LOW)
  }
}
