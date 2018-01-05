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

import org.itemis.types.impl.EVMWord
import org.itemis.blockchain.Transaction
import org.eclipse.xtend.lib.annotations.Accessors
import org.itemis.blockchain.WorldState
import java.util.List
import org.itemis.evm.utils.Patch
import org.itemis.types.UnsignedByte
import org.itemis.evm.EVMOperation.OpCode
import org.itemis.blockchain.Block
import java.util.Optional
import org.itemis.types.UnsignedByteList
import org.itemis.blockchain.BlockchainData
import java.util.Set
import org.itemis.types.impl.Address
import org.itemis.evm.EVMOperation.FeeClass
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.itemis.utils.StaticUtils
import org.itemis.evm.utils.EVMUtils
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonObject

final class EVMRuntime {
  extension EVMUtils e = new EVMUtils
  
  private static final Logger LOGGER = LoggerFactory.getLogger("General")
  private static final Logger EXECUTION_LOGGER = LoggerFactory.getLogger("Execution Feedback")
  private static final Gson GSON = new GsonBuilder().setPrettyPrinting.create
  
  @Accessors private final Thread session
  
  @Accessors private final WorldState worldState
  
  @Accessors private final EVMRuntime parentRuntime
  
  @Accessors private int pc = 0
  private EVMMemory memory = new EVMMemory()
  @Accessors private EVMWord memorySize = EVMWord.ZERO
  private EVMStack stack = new EVMStack()
  private int elementsTakenFromParentStack = 0
  
  @Accessors private EVMWord gasAvailable //doesn't change during execution
  
  @Accessors private Address codeAddress                         //Ia
  @Accessors private Address originAddress                       //Io
  @Accessors private EVMWord gasPrice                            //Ip
  @Accessors private UnsignedByte[] inputData                    //Id
  @Accessors private Address callerAddress                       //Is
  @Accessors private EVMWord value                               //Iv
  @Accessors private Pair<Optional<OpCode>, UnsignedByte>[] code //Ib
  @Accessors private Block currentBlock                          //IH
  @Accessors private EVMWord depth                               //Ie
  
  @Accessors private Patch patch = new Patch() //storage changes
  @Accessors private Set<Address> selfDestructSet = newHashSet
  @Accessors private List<EVMLog> logs = newArrayList
  @Accessors private EVMWord refundBalance = EVMWord.ZERO
  private EVMWord gasUsed = EVMWord.ZERO
  
  @Accessors private byte[] returnValue
  
  new(WorldState ws) {
    this(Thread.currentThread(), ws, null)
  }
  
  private new(Thread t, WorldState ws, EVMRuntime parentRuntime) {
    session = t
    worldState = ws
    this.parentRuntime = parentRuntime
  }
  
  def EVMRuntime createNewAccountRuntime(EVMWord gasAvailable, EVMWord value, byte[] code) {
    val result = createNestedRuntime(gasAvailable)
    
    result.fillEnvironmentInfo(
      codeAddress,
      originAddress,
      gasPrice,
      null, //no data
      codeAddress,
      value,
      code.map[new UnsignedByte(it)].parseCode,
      currentBlock,
      depth.inc
    )
    
    result
  }
  
  def EVMRuntime createNestedRuntime(EVMWord gasAvailable) {
    val result = new EVMRuntime(session, worldState, this)
    
    result.gasAvailable = gasAvailable
    result.memorySize = memorySize
    
    result
  }
  
  def private Pair<Optional<OpCode>, UnsignedByte>[] parseCode(UnsignedByte[] code) {
    parseCode(new UnsignedByteList(code))
  }
  
  def private Pair<Optional<OpCode>, UnsignedByte>[] parseCode(UnsignedByteList code) {
    val result = newArrayOfSize(code.size)
    
    var index = 0
    while(index < code.size) {
      val opCode = EVMOperation.getOp(code.get(index))
      result.set(index, Pair.of(Optional.of(opCode), code.get(index)))
      
      for (var j = 1; j <= EVMOperation.getParameterCount(opCode); j++) {
        result.set(index + j, Pair.of(Optional.empty, code.get(index + j)))
      }
      index += 1 + EVMOperation.getParameterCount(opCode)
    }
    
    result
  }
  
  def void fillEnvironmentInfo(Transaction t) {
    fillEnvironmentInfo(
      t.to,
      t.sender,
      t.gasPrice,
      t.getData,
      t.sender,
      t.value,
      worldState.getCodeAt(t.to).parseCode,
      BlockchainData.getBlockByNumber(worldState.currentBlockNumber),
      EVMWord.ZERO
    )
  }
  
  def void fillEnvironmentInfo(
    Address codeAddress,
    Address originAddress,
    EVMWord gasPrice,
    UnsignedByte[] inputData,
    Address callerAddress,
    EVMWord value,
    UnsignedByteList code,
    Block currentBlock,
    EVMWord depth
  ) {
    fillEnvironmentInfo(
      codeAddress,
      originAddress,
      gasPrice,
      inputData,
      callerAddress,
      value,
      code.parseCode,
      currentBlock,
      depth
    )
  }
  
  def void fillEnvironmentInfo(
    Address codeAddress,
    Address originAddress,
    EVMWord gasPrice,
    UnsignedByte[] inputData,
    Address callerAddress,
    EVMWord value,
    Pair<Optional<OpCode>, UnsignedByte>[] code,
    Block currentBlock,
    EVMWord depth
  ) {
//    LOGGER.trace(String.format(
//      "\ncodeAddr %s\noriginAddr %s\ngasPrice %s\ninputData %s\ncallerAddr %s\nvalue %s\ncode %s\ncurrentBlock number %s\ndepth %s",
//      codeAddress,
//      originAddress,
//      gasPrice,
//      StaticUtils.toHex(inputData),
//      callerAddress,
//      value,
//      StaticUtils.toHex(code.map[value] as UnsignedByte[]),
//      currentBlock.number.toBigInteger,
//      depth
//    ))
    this.codeAddress = codeAddress
    this.originAddress = originAddress
    this.gasPrice = gasPrice
    this.inputData = inputData
    this.callerAddress = callerAddress
    this.value = value
    this.code = code
    this.currentBlock = currentBlock
    this.depth = depth
  }
  
  def private boolean _run() {
    var oldMemorySize = memorySize
    var executedOpCodes = 0
    val executionFeedback = new JsonObject()
    executionFeedback.add("environment", EVMExecutionFeedback.runtimeInfo(this))
    
    var JsonObject halting = null
    
    try {
      while (true) {
        if (pc >= code.length || pc < 0) {
          LOGGER.trace(String.format("memory cost: %s", calcMemoryCost(memorySize).toBigInteger))
          return true //reaching the end of the code -> normal halt
        }
        
        val op = code.get(pc).key.orElseThrow[
          new EVMRuntimeException(String.format("invalid op code at pc %d: %s", pc, code.get(pc).value.toHexString))
        ]
        if (op === null) {
          throw new EVMRuntimeException(String.format("invalid op code at pc %d: %s", pc, code.get(pc).value.toHexString))
        }
        
        val before = EVMExecutionFeedback.before(this)
        halting = EVMExecutionFeedback.before(this)
        oldMemorySize = memorySize
        EVMOperation.executeOp(op, this)
        addGasCost(calcMemoryCost(oldMemorySize).negate)
        addGasCost(calcMemoryCost(memorySize))
        val after = EVMExecutionFeedback.after(this)
        
        val jsonChild = new JsonObject()
        jsonChild.add("before", before)
        jsonChild.add("after", after)
        executionFeedback.add(executedOpCodes.toString, jsonChild)
        executedOpCodes++
        
        if ((op != OpCode.JUMP && op != OpCode.JUMPI) || code.get(pc).key.get == OpCode.JUMPI) {
          pc += 1 + EVMOperation.getParameterCount(op)
        }
      }
    } catch (HaltException h) {
      LOGGER.trace(String.format("halting: %s", h.message))
      addGasCost(calcMemoryCost(oldMemorySize).negate)
      addGasCost(calcMemoryCost(memorySize))
      LOGGER.trace(String.format("memory cost: %s", calcMemoryCost(memorySize).toBigInteger))
        
      val jsonChild = new JsonObject()
      jsonChild.add("before", halting)
      jsonChild.add("after", EVMExecutionFeedback.after(this))
      executionFeedback.add(executedOpCodes.toString + " - halting", jsonChild)
      
      EXECUTION_LOGGER.info(org.itemis.evm.EVMRuntime.GSON.toJson(executionFeedback))
      return true
    } catch (EVMRuntimeException e) {
      if (e.toString.contains("out of gas")) {
        LOGGER.trace(String.format("exception: %s", e.message))
      } else {
        LOGGER.error(String.format("exception: %s", e.message))
        LOGGER.error("\n" + e.stackTrace.map[toString].join("\n"))
      }
      executionFeedback.add("exception", EVMExecutionFeedback.after(this))
      EXECUTION_LOGGER.info(org.itemis.evm.EVMRuntime.GSON.toJson(executionFeedback))
      return false
    }
  }
  
  def private void cleanup() {
    val unusedGas = gasAvailable.sub(gasUsed)
    val refund = EVMWord.min(gasUsed.div(2), refundBalance)
    
    if (parentRuntime === null) {
      patch.addBalance(worldState, callerAddress, unusedGas.mul(gasPrice).add(refund))
      patch.applyChanges(worldState)
    
      worldState.incExecutedTransaction
    } else {
      parentRuntime.patch.mergeOtherPatch(patch)
      
      for (memoryEntry: memory.elements.entrySet) {
        parentRuntime.setMemoryElement(memoryEntry.key, memoryEntry.value)        
      }
      parentRuntime.memorySize = memorySize
      
      for (var i = 0; i < elementsTakenFromParentStack; i++) {
        parentRuntime.popStackItem
      }
      for (stackEntry: stack.elements) {
        parentRuntime.pushStackItem(stackEntry)
      }
      
      parentRuntime.selfDestructSet.addAll(selfDestructSet)
      parentRuntime.logs.addAll(logs)
      parentRuntime.refundBalance.add(refundBalance)
      parentRuntime.gasAvailable.add(gasStillAvailable)
    }
  }
  
  def boolean run() {
    val success = (code.length == 0) || _run
    if (success) {
      cleanup
    }
    success
  }
  
  //returns gasUsed
  def EVMWord executeTransaction(Transaction t) {
    val contractCreation = t.to === null
    if (contractCreation) {
      val rlpList = newArrayList(t.sender.toUnsignedByteArray, worldState.getAccount(t.sender).nonce.trimTrailingZerosAndReverse)
      val rlp = rlp(rlpList)
      val hash = StaticUtils.keccak256(rlp.map[byteValue])
      t.to = new Address(new EVMWord(hash.toByteArray).toByteArray.drop(12))
      LOGGER.trace(String.format("contract creation - new addr %s", t.to))
    }
    
    var sender = worldState.getAccount(t.sender)
    sender.balance = sender.balance.sub(t.gasLimit.mul(t.gasPrice))
    sender.nonce = sender.nonce.inc
    worldState.setAccount(t.sender, sender)
    
//    val recipient = worldState.getAccount(t.to)
//    recipient.nonce = recipient.nonce.inc
//    worldState.setAccount(t.to, recipient)
    
    patch.subtractBalance(worldState, t.sender, t.value)
    patch.addBalance(worldState, t.to, t.value)
    
    pc = 0
    memory.clear
    memorySize = EVMWord.ZERO
    stack.clear
    
    fillEnvironmentInfo(t)
    
    gasAvailable = t.gasLimit
    gasUsed = gasUsed.add(EVMOperation.FEE_SCHEDULE.get(FeeClass.TRANSACTION))
    LOGGER.trace(String.format("gasUsed tx fee: %s", gasUsed.toBigInteger))
    gasUsed = gasUsed.add(EVMOperation.FEE_SCHEDULE.get(FeeClass.TXDATANONZERO).mul(t.data.filter[it.byteValue != 0].length))
    LOGGER.trace(String.format("gasUsed nonzerobytes: %s", gasUsed.toBigInteger))
    gasUsed = gasUsed.add(EVMOperation.FEE_SCHEDULE.get(FeeClass.TXDATAZERO).mul(t.data.filter[it.byteValue == 0].length))
    LOGGER.trace(String.format("gasUsed zerobytes: %s", gasUsed.toBigInteger))
    //TODO: txcreate after homestead
    if (gasAvailable.greaterThan(currentBlock.gasLimit)) {
      LOGGER.debug(String.format("block gasLimit: %s transaction gasLimit %s gasUsed %s", currentBlock.gasLimit.toBigInteger, gasAvailable.toBigInteger, gasUsed.toBigInteger))
      throw new EVMRuntimeException("Trying to use more gas than the block allows")
    } else if (gasAvailable.lessThan(gasUsed)) {
      throw new EVMRuntimeException("Not enough gas for transaction fee")
    } else {
      LOGGER.trace(String.format("gasUsed pre execution: %s", gasUsed.toBigInteger))
    }
    
    if (contractCreation) {
      code = parseCode(t.data)
    }
    val success = _run
    
    if (success) {
      try {
        if (contractCreation) {
          if (returnValue === null) {
            LOGGER.trace("return value is empty, defaulting to empty byte array")
            returnValue = newByteArrayOfSize(0)
          }
          LOGGER.trace(String.format("applying code cost of %d (%d bytes, current gas cost is %s)", 200 * returnValue.length, returnValue.length, gasUsed.toBigInteger))
          addGasCost(new EVMWord(200).mul(returnValue.length))
          
          LOGGER.trace("setting code: " + StaticUtils.toHex(returnValue))
          worldState.setCodeAt(t.to, new UnsignedByteList(returnValue))
        }
        cleanup
      } catch (EVMRuntimeException e) {
        LOGGER.trace("Error when cleaning up: " + e.toString)
        gasUsed = t.gasLimit //TODO this might break
      }
    } else {
      if (contractCreation) {
        LOGGER.trace("contract creation failed")
      }
      gasUsed = t.gasLimit //TODO this might break
    }
    
    gasUsed
  }
  
  def EVMWord popStackItem() {
    if (stack.size == 0) {
      if (parentRuntime === null) {
        throw new EVMRuntimeException("Pop on empty stack")
      } else {
        parentRuntime.getStackItem(elementsTakenFromParentStack++)
      }
    } else {
      stack.pop
    }
  }
  
  def EVMWord getStackItem(int n) {
    if (stack.size <= n) {
      if (parentRuntime === null) {
        throw new EVMRuntimeException("Stack index out of bounds")
      } else {
        parentRuntime.getStackItem(n - stack.size)
      }
    } else {
      stack.get(n)
    }
  }
  
  def pushStackItem(EVMWord value) {
    if (stack.size == EVMStack.EVM_MAX_STACK_SIZE) {
      throw new EVMRuntimeException("Push on full stack")
    }
    stack.push(value)
  }
  
  def EVMWord getGasUsed() {
    gasUsed
  }
  
  def EVMWord getGasStillAvailable() {
    gasAvailable.sub(gasUsed)
  }
  
  def void addGasCost(FeeClass feeClass) {
    addGasCost(EVMOperation.FEE_SCHEDULE.get(feeClass))
  }
  
  def void addGasCost(EVMWord gasAmount) {
    gasUsed = gasUsed.add(gasAmount)
    if (gasUsed.greaterThan(currentBlock.gasLimit)) {
      throw new EVMRuntimeException("Out of gas exception")
    }
  }
  
  def void jump(EVMWord targetPC) {
    jump(targetPC.intValue)
  }
  
  def void jump(int targetPC) {
    if (code.get(targetPC).key.isPresent && code.get(targetPC).key.get == OpCode.JUMPDEST) {
      pc = targetPC
    } else {
      throw new EVMRuntimeException("Invalid jump destination")
    }
  }
  
  def static EVMWord calcMemorySize(EVMWord s, EVMWord f, EVMWord l) {
    if (l.zero) {
      s
    } else {
      val sumRes = f.add(l)
      val divRes = sumRes.div(32)
      val roundedUp = if (divRes.mul(32).equals(sumRes)) {
        divRes
      } else {
        divRes.inc
      }
      EVMWord.max(s, roundedUp)
    }
  }
  
  def static EVMWord calcMemoryCost(EVMWord memorySize) {
    EVMOperation.FEE_SCHEDULE.get(FeeClass.MEMORY).mul(memorySize).add(memorySize.mul(memorySize).div(512))
  }
  
  def Byte getMemoryElement(EVMWord index) {
    if (memory.get(index) != 0) {
      memory.get(index)
    } else if (parentRuntime !== null) {
      parentRuntime.getMemoryElement(index)
    } else {
      0 as byte
    } 
  }
  
  def EVMWord getMemoryWord(EVMWord index) {
    if (!memory.getWord(index).zero) {
      memory.getWord(index)
    } else if (parentRuntime !== null) {
      parentRuntime.getMemoryWord(index)
    } else {
      EVMWord.ZERO
    } 
  }
  
  def void setMemoryElement(EVMWord index, Byte value) {
    memory.put(index, value)
  }
  
  def void setMemoryWord(EVMWord index, EVMWord word) {
    memory.putWord(index, word)
  }
  
  //L(n)
  def static EVMWord allButOne64th(EVMWord n) {
    n.sub(n.div(64))
  }
}