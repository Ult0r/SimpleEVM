/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.evm.op

import org.itemis.evm.EVMOperation
import org.itemis.evm.EVMRuntime
import org.itemis.types.impl.EVMWord
import org.itemis.evm.EVMOperation.FeeClass

abstract class StackMemoryStorageAndFlowOperations {
  def static POP(EVMRuntime runtime) {
    runtime.popStackItem
    runtime.addGasCost(FeeClass.BASE)
  }

  def static MLOAD(EVMRuntime runtime) {
    val s0 = runtime.popStackItem

    runtime.pushStackItem(runtime.getMemoryWord(s0))

    runtime.memorySize = EVMWord.max(runtime.memorySize, s0.add(32).divRoundUp(32))

    runtime.addGasCost(FeeClass.VERYLOW)
  }

  def static MSTORE(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    
    runtime.setMemoryWord(s0, s1)

    runtime.memorySize = EVMWord.max(runtime.memorySize, s0.add(32).divRoundUp(32))

    runtime.addGasCost(FeeClass.VERYLOW)
  }

  def static MSTORE8(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    runtime.setMemoryElement(s0, s1.toByteArray.get(0))

    runtime.memorySize = EVMWord.max(runtime.memorySize, s0.add(1).divRoundUp(32))

    runtime.addGasCost(FeeClass.VERYLOW)
  }

  def static SLOAD(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val storageValue = runtime.patch.getStorageAt(runtime.worldState, runtime.codeAddress, s0)
    runtime.pushStackItem(storageValue)

    runtime.addGasCost(FeeClass.SLOAD)
  }

  def static SSTORE(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    
    var FeeClass cost
    if(!s1.zero && runtime.patch.getStorageAt(runtime.worldState, runtime.codeAddress, s0).zero) {
      cost = FeeClass.SSET
    } else {
      cost = FeeClass.SRESET
    }

    runtime.patch.setStorageValue(runtime.codeAddress, s0, s1)
    runtime.addGasCost(cost)
    runtime.patch.setStorageValue(runtime.codeAddress, s0, s1)
  }

  def static JUMP(EVMRuntime runtime) {
    val s0 = runtime.popStackItem

    runtime.jump(s0)

    runtime.addGasCost(FeeClass.MID)
  }

  def static JUMPI(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    if(!s1.zero) {
      runtime.jump(s0)
    }

    runtime.addGasCost(FeeClass.HIGH)
  }

  def static PC(EVMRuntime runtime) {
    runtime.pushStackItem(new EVMWord(runtime.pc))
    runtime.addGasCost(FeeClass.BASE)

  }

  def static MSIZE(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.memorySize.mul(32))
    runtime.addGasCost(FeeClass.BASE)
  }

  def static GAS(EVMRuntime runtime) {
    val cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE)
    runtime.pushStackItem(runtime.currentBlock.gasLimit.sub(runtime.gasUsed.add(cost)))
    runtime.addGasCost(cost)
  }

  def static JUMPDEST(EVMRuntime runtime) {
    runtime.addGasCost(FeeClass.JUMPDEST)
  }
}
