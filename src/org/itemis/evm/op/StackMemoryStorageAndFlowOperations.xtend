package org.itemis.evm.op

import org.itemis.evm.EVMOperation
import org.itemis.evm.EVMRuntime
import org.itemis.types.EVMWord
import org.itemis.evm.EVMOperation.FeeClass

abstract class StackMemoryStorageAndFlowOperations {
  def static POP(EVMRuntime runtime) {
    runtime.popStackItem
    runtime.gasUsed.add(EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE))
  }

  def static MLOAD(EVMRuntime runtime) {
    val s0 = runtime.popStackItem

    val bytes = newByteArrayOfSize(32)
    for (var i = 0; i < 32; i++) {
      bytes.set(i, runtime.memory.get(s0.add(new EVMWord(i))))
    }
    runtime.pushStackItem(new EVMWord(bytes))

    runtime.memorySize = EVMRuntime.calcMemorySize(runtime.memorySize, s0, new EVMWord(32))

    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static MSTORE(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    val bytes = s1.toByteArray
    for (var i = 0; i < 32; i++) {
      runtime.memory.put(s0.add(new EVMWord(i)), bytes.get(i))
    }

    runtime.memorySize = EVMRuntime.calcMemorySize(runtime.memorySize, s0, new EVMWord(32))

    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static MSTORE8(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    runtime.memory.put(s0, s1.toByteArray.get(0))

    runtime.memorySize = EVMRuntime.calcMemorySize(runtime.memorySize, s0, new EVMWord(1))

    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static SLOAD(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    runtime.pushStackItem(runtime.patch.getStorageAt(runtime.worldState, runtime.codeAddress, s0))

    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.SLOAD))
  }

  def static SSTORE(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    var EVMWord cost
    if(!s1.zero && runtime.patch.getStorageAt(runtime.worldState, runtime.codeAddress, s0).zero) {
      cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.SSET)
    } else {
      cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.SRESET)
    }

    runtime.patch.setStorageValue(runtime.codeAddress, s0, s1)
    runtime.addGasCost(cost)
    runtime.patch.setStorageValue(runtime.codeAddress, s0, s1)
  }

  def static JUMP(EVMRuntime runtime) {
    val s0 = runtime.popStackItem

    runtime.jump(s0)

    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.MID))
  }

  def static JUMPI(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    if(!s1.zero) {
      runtime.jump(s0)
    }

    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.HIGH))
  }

  def static PC(EVMRuntime runtime) {
    runtime.pushStackItem(new EVMWord(runtime.pc))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE))

  }

  def static MSIZE(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.memorySize.mul(new EVMWord(32)))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE))
  }

  def static GAS(EVMRuntime runtime) {
    val cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE)
    runtime.pushStackItem(runtime.currentBlock.gasLimit.sub(runtime.gasUsed.add(cost)))
    runtime.addGasCost(cost)
  }

  def static JUMPDEST(EVMRuntime runtime) {
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.JUMPDEST))
  }
}
