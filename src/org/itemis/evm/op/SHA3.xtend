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
import org.itemis.utils.StaticUtils

abstract class SHA3 {
  def static SHA3(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem

    var counter = new EVMWord(s0)
    val topBorder = s0.add(s1)

    val list = newArrayList
    while(counter.lessThan(topBorder)) {
      list.add(runtime.getMemoryElement(counter))
      counter.inc
    }

    runtime.pushStackItem(StaticUtils.keccak256(list).toEVMWord)
    runtime.memorySize = EVMRuntime.calcMemorySize(runtime.memorySize, s0, s1)

    val var_cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.SHA3WORD).mul(s1.divRoundUp(32))
    runtime.addGasCost(FeeClass.SHA3)
    runtime.addGasCost(var_cost)
  }
}
