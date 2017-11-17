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
import org.itemis.types.UnsignedByte
import org.itemis.evm.utils.StaticEVMUtils
import org.itemis.utils.StaticUtils
import org.itemis.blockchain.Account
import org.itemis.types.UnsignedByteList
import org.itemis.evm.EVMOperation

abstract class SystemOperations {
  //TODO: does gas cost get deducted no matter if create/call/etc successful?
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
      val contractRuntime = runtime.createNewAccountRuntime(EVMRuntime.allButOne64th(runtime.gasStillAvailable), s0, i)
      contractRuntime.patch = runtime.patch
      
      val rlpList = newArrayList(runtime.codeAddress.toUnsignedByteArray, runtime.worldState.getAccount(runtime.codeAddress).nonce.dec.toUnsignedByteArray)
      val rlp = StaticEVMUtils.rlp(rlpList)
      val hash = StaticUtils.keccak256(rlp.map[byteValue])
      val newAddress = new Address(new EVMWord(hash.toByteArray))
      
      runtime.worldState.putAccount(runtime.currentBlock.number, newAddress, new Account(s0))
      
      if(contractRuntime.run) {
        runtime.getSelfDestructSet.addAll(contractRuntime.getSelfDestructSet)
        runtime.logs.addAll(contractRuntime.logs)
        runtime.refundBalance.add(contractRuntime.refundBalance)
        runtime.gasAvailable = runtime.gasAvailable.add(contractRuntime.gasStillAvailable)

        runtime.worldState.setCodeAt(newAddress, new UnsignedByteList(contractRuntime.returnValue))
        
        runtime.patch = contractRuntime.patch

        runtime.pushStackItem(newAddress.toEVMWord)

        runtime.addGasCost(FeeClass.CREATE)
      } else {
        runtime.pushStackItem(EVMWord.ZERO)
      }
    } else {
      runtime.pushStackItem(EVMWord.ZERO)
    }

    runtime.memorySize = EVMRuntime.calcMemorySize(runtime.memorySize, s1, s2)
  }

  def static CALL(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = new Address(runtime.popStackItem)
    val s2 = runtime.popStackItem
    val s3 = runtime.popStackItem
    val s4 = runtime.popStackItem
    val s5 = runtime.popStackItem
    val s6 = runtime.popStackItem

    val balance = runtime.patch.getBalance(runtime.worldState, runtime.callerAddress)
    
    val cNew = if (runtime.worldState.accountExists(s1)) EVMOperation.FEE_SCHEDULE.get(FeeClass.NEWACCOUNT) else EVMWord.ZERO
    val cXfer = if (!s2.zero) EVMOperation.FEE_SCHEDULE.get(FeeClass.CALLVALUE) else EVMWord.ZERO
    val cExtra = EVMOperation.FEE_SCHEDULE.get(FeeClass.CALL).add(cXfer).add(cNew)
    val cGascap = if (runtime.gasAvailable.greaterThanEquals(cExtra)) {
      EVMWord.min(EVMRuntime.allButOne64th(runtime.gasAvailable.sub(cExtra)), s0)
    } else {
      s0
    }
//    val cCallgas = if (!s2.zero) cGascap.add(EVMOperation.FEE_SCHEDULE.get(FeeClass.CALLSTIPEND)) else cGascap
    val cCall = cGascap.add(cExtra)
    
    val i = newByteArrayOfSize(s4.intValue)
    for (var j = 0; j < s4.intValue; j++) {
      i.set(j, runtime.memory.get(s3.add(j)))
    }
    
    if (s2.lessThanEquals(balance) && runtime.depth.intValue < 1024) {
      val o = runtime.worldState.getCodeAt(s1) 
      val n = EVMWord.min(s6, new EVMWord(o.size))
      
      for (var j = 0; j < n.intValue - 1; j++) {
        runtime.memory.put(s5.add(j), o.get(j).byteValue)
      }
      
      val contractRuntime = runtime.createNestedRuntime(s0, s1, s2, o.elements.map[byteValue])
      contractRuntime.fillEnvironmentInfo(
        s1,
        runtime.originAddress,
        runtime.gasPrice,
        i.map[new UnsignedByte(it)],
        runtime.codeAddress,
        s2,
        runtime.worldState.getCodeAt(s1),
        runtime.currentBlock,
        runtime.depth.inc
      )
      contractRuntime.patch = runtime.patch
      
      if(contractRuntime.run) {
        runtime.getSelfDestructSet.addAll(contractRuntime.getSelfDestructSet)
        runtime.logs.addAll(contractRuntime.logs)
        runtime.refundBalance.add(contractRuntime.refundBalance)
        runtime.gasAvailable = runtime.gasAvailable.add(contractRuntime.gasStillAvailable)

        runtime.patch = contractRuntime.patch

        runtime.pushStackItem(EVMWord.ONE)
      } else {
        runtime.pushStackItem(EVMWord.ZERO)
      }
    } else {
      runtime.pushStackItem(EVMWord.ZERO)
    }
    
    runtime.memorySize = EVMRuntime.calcMemorySize(EVMRuntime.calcMemorySize(runtime.memorySize, s3, s4), s5, s6)

    runtime.addGasCost(cCall)
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
