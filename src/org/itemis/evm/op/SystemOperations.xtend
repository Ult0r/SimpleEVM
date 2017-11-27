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
import org.itemis.evm.HaltException
import java.util.Optional
import java.util.Arrays
import java.math.BigInteger
import org.itemis.types.impl.Hash256

abstract class SystemOperations {
  def static CREATE(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    val s2 = runtime.popStackItem

    val balance = runtime.patch.getBalance(runtime.worldState, runtime.callerAddress)
    val nonce = runtime.patch.getNonce(runtime.worldState, runtime.callerAddress)

    val i = newByteArrayOfSize(s2.intValue)
    for (var j = 0; j < s2.intValue; j++) {
      i.set(j, runtime.getMemoryElement(s1.add(j)))
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
        runtime.worldState.setCodeAt(newAddress, new UnsignedByteList(contractRuntime.returnValue))
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
  
  def private static Optional<EVMRuntime> ECDSARECOVER(EVMRuntime runtime, byte[] data) {
    val returnRuntime = runtime.createNestedRuntime(EVMWord.ZERO)
    
    val d = Arrays.copyOf(data, 128)
    
    val h = new Hash256(d.subList(0, 32))
    val v = new Integer(d.get(63)) //XXX: or 32
    val r = new BigInteger(d.subList(64, 96))
    val s = new BigInteger(d.subList(96, 128))
    
    try {
      val hash = StaticUtils.keccak256(StaticUtils.ECDSARecover(v, s, r, h)).toByteArray
      returnRuntime.returnValue = newByteArrayOfSize(32)
      System.arraycopy(hash, 12, returnRuntime.returnValue, 12, 20)
      Optional.of(returnRuntime)
    } catch (Exception e) {
      Optional.empty
    }
  }
  
  def private static Optional<EVMRuntime> SHA256(EVMRuntime runtime, byte[] data) {
    val returnRuntime = runtime.createNestedRuntime(EVMWord.ZERO)
    
    val hash = StaticUtils.sha2_256(data).toByteArray
    returnRuntime.returnValue = newByteArrayOfSize(32)
    System.arraycopy(hash, 0, returnRuntime.returnValue, 0, 32)
    
    Optional.of(returnRuntime)
  }
  
  def private static Optional<EVMRuntime> RIPEMD_160(EVMRuntime runtime, byte[] data) {
    val returnRuntime = runtime.createNestedRuntime(EVMWord.ZERO)
    
    val hash = StaticUtils.ripemd_160(data).toByteArray
    returnRuntime.returnValue = newByteArrayOfSize(32)
    System.arraycopy(hash, 0, returnRuntime.returnValue, 12, 20)
    
    Optional.of(returnRuntime)
  }
  
  def private static Optional<EVMRuntime> ID(EVMRuntime runtime, byte[] data) {
    val returnRuntime = runtime.createNestedRuntime(EVMWord.ZERO)
    
    returnRuntime.returnValue = newByteArrayOfSize(data.length)
    System.arraycopy(data, 0, returnRuntime.returnValue, 0, data.length)
    
    Optional.of(returnRuntime)
  }
  
  def private static Optional<EVMRuntime> pre(int address, EVMRuntime runtime, EVMWord gasAvailable, byte[] data) {
    switch address {
      case 1: {
        if (gasAvailable.greaterThanEquals(new EVMWord(3000))) {
          ECDSARECOVER(runtime, data)
        } else {
          Optional.empty
        }
      }
      case 2: {
        val cost = new EVMWord(60).add(new EVMWord(12).mul(new EVMWord(data.length).divRoundUp(32)))
        if (gasAvailable.greaterThanEquals(cost)) {
          SHA256(runtime, data)
        } else {
          Optional.empty
        }
      }
      case 3: {
        val cost = new EVMWord(600).add(new EVMWord(120).mul(new EVMWord(data.length).divRoundUp(32)))
        if (gasAvailable.greaterThanEquals(cost)) {
          RIPEMD_160(runtime, data)
        } else {
          Optional.empty
        }
      }
      case 4: {
        val cost = new EVMWord(15).add(new EVMWord(3).mul(new EVMWord(data.length).divRoundUp(32)))
        if (gasAvailable.greaterThanEquals(cost)) {
          ID(runtime, data)
        } else {
          Optional.empty
        }
      }
    }
  }
  
  //returns unused gas
  def private static Optional<EVMRuntime> sigma(EVMRuntime runtime, Address sender, Address origin, Address recipient, Address codeAddress, EVMWord gasAvailable, EVMWord gasPrice, EVMWord value, EVMWord apparentValue, byte[] data, EVMWord depth) {
    if (recipient.toEVMWord.intValue <= 4) {
      pre(recipient.toEVMWord.intValue, runtime, gasAvailable, data)
    } else {
      val contractRuntime = runtime.createNestedRuntime(gasAvailable)
      contractRuntime.fillEnvironmentInfo(
        recipient,
        origin,
        gasPrice,
        data.map[new UnsignedByte(it)],
        sender,
        apparentValue,
        runtime.worldState.getCodeAt(codeAddress),
        runtime.currentBlock,
        depth
      )
      
      if (contractRuntime.run) {
        runtime.pushStackItem(EVMWord.ONE)
        Optional.of(contractRuntime)
      } else {
        runtime.pushStackItem(EVMWord.ZERO)
        Optional.empty
      }
    }
  }
  
  def private static EVMWord CCALL(EVMRuntime runtime, EVMWord s0, Address s1, EVMWord s2) {
    val cNew = if (runtime.patch.accountExists(runtime.worldState, s1)) EVMOperation.FEE_SCHEDULE.get(FeeClass.NEWACCOUNT) else EVMWord.ZERO
    val cXfer = if (!s2.zero) EVMOperation.FEE_SCHEDULE.get(FeeClass.CALLVALUE) else EVMWord.ZERO
    val cExtra = EVMOperation.FEE_SCHEDULE.get(FeeClass.CALL).add(cXfer).add(cNew)
    val cGascap = if (runtime.gasAvailable.greaterThanEquals(cExtra)) {
      EVMWord.min(EVMRuntime.allButOne64th(runtime.gasAvailable.sub(cExtra)), s0)
    } else {
      s0
    }
    cGascap.add(cExtra)
  }
  
  def private static EVMWord CCALLGAS(EVMRuntime runtime, EVMWord s0, Address s1, EVMWord s2) {
    val cNew = if (runtime.patch.accountExists(runtime.worldState, s1)) EVMOperation.FEE_SCHEDULE.get(FeeClass.NEWACCOUNT) else EVMWord.ZERO
    val cXfer = if (!s2.zero) EVMOperation.FEE_SCHEDULE.get(FeeClass.CALLVALUE) else EVMWord.ZERO
    val cExtra = EVMOperation.FEE_SCHEDULE.get(FeeClass.CALL).add(cXfer).add(cNew)
    val cGascap = if (runtime.gasAvailable.greaterThanEquals(cExtra)) {
      EVMWord.min(EVMRuntime.allButOne64th(runtime.gasAvailable.sub(cExtra)), s0)
    } else {
      s0
    }
    if (!s2.zero) cGascap.add(EVMOperation.FEE_SCHEDULE.get(FeeClass.CALLSTIPEND)) else cGascap
  }

  //isCall opposing to isCallCode
  def private static _CALL(EVMRuntime runtime, boolean isCall) {
    val s0 = runtime.popStackItem
    val s1 = new Address(runtime.popStackItem)
    val s2 = runtime.popStackItem
    val s3 = runtime.popStackItem
    val s4 = runtime.popStackItem
    val s5 = runtime.popStackItem
    val s6 = runtime.popStackItem
    
    val balance = runtime.patch.getBalance(runtime.worldState, runtime.callerAddress)
    
    val cCall = CCALL(runtime, s0, s1, s2)
    
    val i = newByteArrayOfSize(s4.intValue)
    for (var j = 0; j < s4.intValue; j++) {
      i.set(j, runtime.getMemoryElement(s3.add(j)))
    }
      
    runtime.memorySize = EVMRuntime.calcMemorySize(EVMRuntime.calcMemorySize(runtime.memorySize, s3, s4), s5, s6)
    runtime.addGasCost(cCall)
    
    val gasPassed = CCALLGAS(runtime, s0, s1, s2)
    
    if (s2.lessThanEquals(balance) && runtime.depth.intValue < 1024) {
      val contractRuntime = sigma(
        runtime,
        runtime.codeAddress,
        runtime.originAddress,
        if (isCall) s1 else runtime.codeAddress,
        s1,
        gasPassed,
        runtime.gasPrice,
        s2,
        s2,
        i,
        runtime.depth.inc
      )
      
      if (contractRuntime.present) {
        runtime.addGasCost(contractRuntime.get.gasStillAvailable.negate)
    
        val o = contractRuntime.get.returnValue
        val n = EVMWord.min(s6, new EVMWord(o.size))
        for (var j = 0; j < n.intValue - 1; j++) {
          runtime.setMemoryElement(s5.add(j), o.get(j).byteValue)
        }
      } else {
        runtime.addGasCost(gasPassed.negate)
      }
    }
  }
  
  def static CALL(EVMRuntime runtime) {
    _CALL(runtime, true)
  }

  def static CALLCODE(EVMRuntime runtime) {
    _CALL(runtime, false)
  }

  def static RETURN(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    
    runtime.returnValue = newByteArrayOfSize(s1.intValue)
    for (var i = 0; i < s1.intValue; i++) {
      runtime.returnValue.set(i, runtime.getMemoryElement(s0.add(i)))
    }
    
    runtime.memorySize = EVMRuntime.calcMemorySize(runtime.memorySize, s0, s1)
    
    throw new HaltException("RETURN")
  }

  def static DELEGATECALL(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = new Address(runtime.popStackItem)
    //s2 is being omitted here, keeping other names for the sake of consistency with CALL
    val s3 = runtime.popStackItem
    val s4 = runtime.popStackItem
    val s5 = runtime.popStackItem
    val s6 = runtime.popStackItem
    
    val balance = runtime.patch.getBalance(runtime.worldState, runtime.callerAddress)
    
    val cCall = CCALL(runtime, s0, s1, runtime.value)
    
    val i = newByteArrayOfSize(s4.intValue)
    for (var j = 0; j < s4.intValue; j++) {
      i.set(j, runtime.getMemoryElement(s3.add(j)))
    }
    
    runtime.memorySize = EVMRuntime.calcMemorySize(EVMRuntime.calcMemorySize(runtime.memorySize, s3, s4), s5, s6)
    runtime.addGasCost(cCall)
    
    if (runtime.value.lessThanEquals(balance) && runtime.depth.intValue < 1024) {
      val contractRuntime = sigma(
        runtime,
        runtime.callerAddress,
        runtime.originAddress,
        runtime.codeAddress,
        s1,
        s0,
        runtime.gasPrice,
        EVMWord.ZERO,
        runtime.value,
        i,
        runtime.depth.inc
      )
      
      if (contractRuntime.present) {
        runtime.addGasCost(contractRuntime.get.gasStillAvailable.negate)
    
        val o = contractRuntime.get.returnValue
        val n = EVMWord.min(s6, new EVMWord(o.size))
        for (var j = 0; j < n.intValue - 1; j++) {
          runtime.setMemoryElement(s5.add(j), o.get(j).byteValue)
        }
      } else {
        runtime.addGasCost(s0.negate)
      }
    }
  }

  def static INVALID(EVMRuntime runtime) {
    throw new RuntimeException("INVALID instruction")
  }

  def static SELFDESTRUCT(EVMRuntime runtime) {
    val s0 = new Address(runtime.popStackItem)

    if (!runtime.selfDestructSet.contains(runtime.codeAddress)) {
      runtime.refundBalance.add(EVMOperation.FEE_SCHEDULE.get(FeeClass.SELFDESTRUCT_R))
    }    
    runtime.selfDestructSet.add(runtime.codeAddress)
    runtime.patch.addBalance(runtime.worldState, s0, runtime.patch.getBalance(runtime.worldState, runtime.codeAddress))
    runtime.patch.setBalance(runtime.codeAddress, EVMWord.ZERO)
    
    runtime.addGasCost(FeeClass.SELFDESTRUCT)
    if (!runtime.patch.accountExists(runtime.worldState, s0)) {
      runtime.addGasCost(FeeClass.NEWACCOUNT)
    }
    
    throw new HaltException("SELFDESTRUCT")
  }
}
