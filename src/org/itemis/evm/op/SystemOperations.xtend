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

import org.itemis.evm.EVMRuntime
import org.itemis.types.impl.EVMWord
import org.itemis.evm.EVMOperation.FeeClass
import org.itemis.types.impl.Address

abstract class SystemOperations {
  def static CREATE(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    val s2 = runtime.popStackItem

    val balance = runtime.patch.getBalance(runtime.worldState, runtime.callerAddress)
    val nonce = runtime.patch.getNonce(runtime.worldState, runtime.callerAddress)

    val i = newByteArrayOfSize(s2.intValue)
    for (var j = 0; j < s2.intValue; j++) {
      i.set(j, runtime.memory.get(s1.add(j)))
    }

    if(s0.lessThanEquals(balance) && runtime.depth.intValue < 1024) {
      runtime.patch.setNonce(runtime.callerAddress, nonce.inc)
      val contractRuntime = runtime.createNestedRuntime(s0, i)
      contractRuntime.patch = runtime.patch

      if(contractRuntime.run) {
        runtime.getSelfDestructSet.addAll(contractRuntime.getSelfDestructSet)
        runtime.logs.addAll(contractRuntime.logs)
        runtime.refundBalance.add(contractRuntime.refundBalance)

        runtime.patch = contractRuntime.patch

        runtime.pushStackItem(new EVMWord(1337)) // TODO: new account address
      } else {
        runtime.pushStackItem(EVMWord.ZERO)
      }
    } else {
      runtime.pushStackItem(EVMWord.ZERO)
    }

    runtime.memorySize = EVMRuntime.calcMemorySize(runtime.memorySize, s1, s2)

    runtime.addGasCost(FeeClass.CREATE)
  }

  def static CALL(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    val s2 = runtime.popStackItem
    val s3 = runtime.popStackItem
    val s4 = runtime.popStackItem
    val s5 = runtime.popStackItem
    val s6 = runtime.popStackItem
    val s7 = runtime.popStackItem

    val balance = runtime.patch.getBalance(runtime.worldState, runtime.callerAddress)
    val nonce = runtime.patch.getNonce(runtime.worldState, runtime.callerAddress)
    
    val i = newByteArrayOfSize(s4.intValue)
    for (var j = 0; j < s4.intValue; j++) {
      i.set(j, runtime.memory.get(s3.add(j)))
    }
    
    if (s2.lessThanEquals(balance) && runtime.depth.intValue < 1024) {
      val addr = new Address(s1) 
      val o = runtime.worldState.getCodeAt(addr) 
      val n = EVMWord.min(s6, new EVMWord(o.size))
      
      for (var j = 0; j < n.intValue - 1; j++) {
        runtime.memory.put(s5.add(j), o.get(j).byteValue)
      }
      
      val contractRuntime = runtime.createNestedRuntime(s2, o.elements.map[byteValue])
      contractRuntime.fillEnvironmentInfo(
        s1, 
      )
      
    } else {
      runtime.pushStackItem(EVMWord.ZERO)
    }
    
    
    
    // TODO  
  }

  def static CALLCODE(EVMRuntime runtime) {
    // TODO  
  }

  def static RETURN(EVMRuntime runtime) {
    // TODO  
  }

  def static DELEGATECALL(EVMRuntime runtime) {
    // TODO  
  }

  def static INVALID(EVMRuntime runtime) {
    // TODO  
  }

  def static SELFDESTRUCT(EVMRuntime runtime) {
    // TODO  
  }
}
