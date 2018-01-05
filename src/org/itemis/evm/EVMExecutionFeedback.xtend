/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/

package org.itemis.evm

import org.itemis.evm.EVMOperation.OpCode
import com.google.gson.JsonObject
import com.google.gson.JsonNull
import com.google.gson.JsonElement
import org.itemis.utils.StaticUtils
import java.text.SimpleDateFormat
import java.util.Date
import java.util.List
import org.itemis.types.impl.EVMWord
import org.itemis.types.UnsignedByte

abstract class EVMExecutionFeedback {
  private static final List<EVMWord> afterStack = newArrayList
  
  static def JsonObject runtimeInfo(EVMRuntime runtime) {
    val runtimeObject = new JsonObject()
    runtimeObject.addProperty("codeAddress", runtime.codeAddress.toString)
    runtimeObject.addProperty("originAddress", runtime.originAddress.toString)
    runtimeObject.addProperty("gasPrice", runtime.gasPrice.toBigInteger.toString)
    runtimeObject.addProperty("inputData", StaticUtils.toHex(runtime.inputData))
    runtimeObject.addProperty("callerAddress", runtime.callerAddress.toString)
    runtimeObject.addProperty("value", runtime.value.toBigInteger.toString)
    runtimeObject.addProperty("code", StaticUtils.toHex(runtime.code.map[it.value]))
    
    val blockObject = new JsonObject()
    blockObject.addProperty("parentHash", runtime.currentBlock.parentHash.toString)
    blockObject.addProperty("ommersHash", runtime.currentBlock.ommersHash.toString)
    blockObject.addProperty("beneficiary", runtime.currentBlock.beneficiary.toString)
    blockObject.addProperty("stateRoot", runtime.currentBlock.stateRoot.toString)
    blockObject.addProperty("transactionsRoot", runtime.currentBlock.transactionsRoot.toString)
    blockObject.addProperty("receiptsRoot", runtime.currentBlock.receiptsRoot.toString)
    blockObject.addProperty("logsBloom", runtime.currentBlock.logsBloom.toString)
    blockObject.addProperty("difficulty", runtime.currentBlock.difficulty.toBigInteger.toString)
    blockObject.addProperty("number", runtime.currentBlock.number.toBigInteger.toString)
    blockObject.addProperty("gasLimit", runtime.currentBlock.gasLimit.toBigInteger.toString)
    blockObject.addProperty("gasUsed", runtime.currentBlock.gasUsed.toBigInteger.toString)
    blockObject.addProperty("timestamp", runtime.currentBlock.timestamp.toString)
    blockObject.addProperty("extraData", StaticUtils.toHex(runtime.currentBlock.extraData))
    blockObject.addProperty("mixHash", runtime.currentBlock.mixHash.toString)
    blockObject.addProperty("nonce", runtime.currentBlock.nonce.toString)
    val ommersObject = new JsonObject()
    for (var i = 0; i < runtime.currentBlock.ommers.length; i++) {
      ommersObject.addProperty(i.toString, runtime.currentBlock.ommers.get(i).toString)
    }
    blockObject.add("ommers", ommersObject)
    val transactionsObject = new JsonObject()
    for (var i = 0; i < runtime.currentBlock.transactions.length; i++) {
      transactionsObject.addProperty(i.toString, runtime.currentBlock.transactions.get(i).hash.toString)
    }
    blockObject.add("transactions", transactionsObject)
    runtimeObject.add("currentBlock", blockObject)
    
    runtimeObject.addProperty("depth", runtime.depth.toBigInteger.toString)
    runtimeObject
  }
  
  static def JsonObject before(EVMRuntime runtime) {
    feedback(runtime.code.get(runtime.pc).key.get, runtime.pc, runtime, true)
  }
  
  static def JsonObject after(EVMRuntime runtime) {
    feedback(runtime.code.get(runtime.pc).key.get, runtime.pc, runtime, false)
  }
  
  def private static feedback(OpCode opCode, int pc, EVMRuntime runtime, boolean before) {
    val opInfo = EVMOperation.OP_INFO.get(opCode)
    
    val result = new JsonObject()
    
    result.addProperty("timestamp", new SimpleDateFormat("dd/MM/yyyy HH:mm:ss:SSS").format(new Date(System.currentTimeMillis)))
    result.addProperty("beforeExecution", before)
    result.addProperty("opCode", opCode.toString)
    
    //parameters
    if (before && EVMOperation.getParameterCount(opCode) != 0) {
      val parameterObject = new JsonObject()
      for (var i = 1; i <= EVMOperation.getParameterCount(opCode); i++) {
        parameterObject.addProperty(i.toString, runtime.code.get(pc + i).value.toHexString)
      }
      result.add("parameters", parameterObject)
    } else if (before) {
      result.add("parameters", JsonNull.INSTANCE)
    }
    
    result.addProperty("pc", pc)
    result.addProperty("memorySize", runtime.memorySize.toBigInteger)
    result.addProperty("gasUsed", runtime.gasUsed.toBigInteger)
    
    //stack manipulation
    if ((!opInfo.middle.key.zero && before) || (!opInfo.middle.value.zero && !before)) {
      val stackObject = new JsonObject()
      val stackElementsToShow = if (before) opInfo.middle.key else opInfo.middle.value
      for (var i = 0; i < stackElementsToShow.intValue; i++) {
        stackObject.addProperty(i.toString, runtime.getStackItem(i).toString)
      }
      result.add("stack", stackObject)
      
      if (before) {
        afterStack.clear
        for (var i = 0; i < opInfo.middle.key.intValue; i++) {
          afterStack.add(runtime.getStackItem(i))
        }
      }
    } else {
      result.add("stack", JsonNull.INSTANCE)
    }
    
    //memory manipulation
    var JsonElement memoryElement = null
    var memoryObject = new JsonObject()
    switch (opCode) {
      case SHA3: {
        if (before) {
          val s0 = runtime.getStackItem(0)
          for (var i = 0; i < runtime.getStackItem(1).intValue; i++) {
            memoryObject.addProperty(s0.add(i).toString, new UnsignedByte(runtime.getMemoryElement(s0.add(i))).toHexString)
          }
        }
      }
      case CALLDATACOPY,
      case CODECOPY: {
        val s0 = if (before) runtime.getStackItem(0) else afterStack.get(0)
        val s2 = if (before) runtime.getStackItem(2) else afterStack.get(2)
        for (var i = 0; i < s2.intValue; i++) {
          memoryObject.addProperty(s0.add(i).toString, new UnsignedByte(runtime.getMemoryElement(s0.add(i))).toHexString) 
        }
      }
      case EXTCODECOPY: {
        val s1 = if (before) runtime.getStackItem(1) else afterStack.get(1)
        val s3 = if (before) runtime.getStackItem(3) else afterStack.get(3)
        for (var i = 0; i < s3.intValue; i++) {
          memoryObject.addProperty(s1.add(i).toString, new UnsignedByte(runtime.getMemoryElement(s1.add(i))).toHexString) 
        }
      }
      case MLOAD: {
        if (before) {
          val s0 = runtime.getStackItem(0)
          for (var i = 0; i < 32; i++) {
            memoryObject.addProperty(s0.add(i).toString, new UnsignedByte(runtime.getMemoryElement(s0.add(i))).toHexString) 
          }
        }
      }
      case MSTORE: {
        val s0 = if (before) runtime.getStackItem(0) else afterStack.get(0)
        for (var i = 0; i < 32; i++) {
          memoryObject.addProperty(s0.add(i).toString, new UnsignedByte(runtime.getMemoryElement(s0.add(i))).toHexString) 
        }
      }
      case MSTORE8: {
        val s0 = if (before) runtime.getStackItem(0) else afterStack.get(0)
        memoryObject.addProperty(s0.toString, new UnsignedByte(runtime.getMemoryElement(s0)).toHexString) 
      }
      case CREATE: {
        if (before) {
          val s1 = runtime.getStackItem(1)
          for (var i = 0; i < runtime.getStackItem(2).intValue; i++) {
            memoryObject.addProperty(s1.add(i).toString, new UnsignedByte(runtime.getMemoryElement(s1.add(i))).toHexString) 
          }
        }
      }
      case CALL,
      case CALLCODE: {
        if (before) {
          val s3 = runtime.getStackItem(3)
          for (var i = 0; i < runtime.getStackItem(4).intValue; i++) {
            memoryObject.addProperty(s3.add(i).toString, new UnsignedByte(runtime.getMemoryElement(s3.add(i))).toHexString) 
          }
        }
      }
      case RETURN: {
        if (before) {
          val s0 = runtime.getStackItem(0)
          for (var i = 0; i < runtime.getStackItem(1).intValue; i++) {
            memoryObject.addProperty(s0.add(i).toString, new UnsignedByte(runtime.getMemoryElement(s0.add(i))).toHexString) 
          }
        }
      }
      case DELEGATECALL: {
        if (before) {
          val s2 = runtime.getStackItem(2)
          for (var i = 0; i < runtime.getStackItem(3).intValue; i++) {
            memoryObject.addProperty(s2.add(i).toString, new UnsignedByte(runtime.getMemoryElement(s2.add(i))).toHexString) 
          }
        }
      }
      default: memoryElement = JsonNull.INSTANCE
    }
    if (memoryElement === null) {
      memoryElement = memoryObject
    }
    result.add("memory", memoryElement)
    
    var JsonElement storageElement = null
    var storageObject = new JsonObject()
    switch (opCode) {
      case SLOAD: {
        if (before) {
          val s0 = runtime.getStackItem(0)
          storageObject.addProperty(s0.toString, runtime.patch.getStorageAt(runtime.worldState, runtime.codeAddress, s0).toString)
        }
      }
      case SSTORE: {
        val s0 = if (before) runtime.getStackItem(0) else afterStack.get(0)
        storageObject.addProperty(s0.toString, runtime.patch.getStorageAt(runtime.worldState, runtime.codeAddress, s0).toString)
      }
      default: storageElement = JsonNull.INSTANCE
    }
    if (storageElement === null) {
      storageElement = storageObject
    }
    result.add("storage", storageElement)
    
    result    
  } 
}























