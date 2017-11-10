package org.itemis.evm.op

import org.itemis.evm.EVMOperation
import org.itemis.evm.EVMRuntime
import org.itemis.types.EVMWord
import org.itemis.evm.EVMOperation.FeeClass

abstract class ComparisonAndBitwiseLogicOperations {
  def static EQ(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    runtime.pushStackItem(if(s0.equals(s1)) EVMWord.ONE else EVMWord.ZERO)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static GT(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    runtime.pushStackItem(
      if(s1.toUnsignedBigInteger.subtract(s0.toUnsignedBigInteger).signum == -1) EVMWord.ONE else EVMWord.ZERO)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static LT(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    runtime.pushStackItem(
      if(s0.toUnsignedBigInteger.subtract(s1.toUnsignedBigInteger).signum == -1) EVMWord.ONE else EVMWord.ZERO)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static SGT(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    runtime.pushStackItem(if(s0.greaterThan(s1)) EVMWord.ONE else EVMWord.ZERO)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static SLT(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    runtime.pushStackItem(if(s0.lessThan(s1)) EVMWord.ONE else EVMWord.ZERO)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static ISZERO(EVMRuntime runtime) {
    val s0 = runtime.popStackItem

    runtime.pushStackItem(if(s0.zero) EVMWord.ONE else EVMWord.ZERO)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static AND(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    runtime.pushStackItem(EVMWord.fromBigInteger(s0.toBigInteger.and(s1.toBigInteger)))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static OR(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    runtime.pushStackItem(EVMWord.fromBigInteger(s0.toBigInteger.or(s1.toBigInteger)))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static XOR(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    runtime.pushStackItem(EVMWord.fromBigInteger(s0.toBigInteger.xor(s1.toBigInteger)))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static NOT(EVMRuntime runtime) {
    val s0 = runtime.popStackItem

    runtime.pushStackItem(EVMWord.fromBigInteger(s0.toBigInteger.not))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static BYTE(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    if(s0.lessThan(new EVMWord(32))) {
      runtime.pushStackItem(new EVMWord(s1.getNthField(31 - s0.getNthField(0).intValue).intValue))
    } else {
      runtime.pushStackItem(EVMWord.ZERO)
    }
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }
}
