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

final class EVMRuntime {
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
    this(ws, null)
  }
  
  private new(WorldState ws, EVMRuntime parentRuntime) {
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
      new UnsignedByteList(code.map[new UnsignedByte(it)]).parseCode,
      currentBlock,
      depth.inc
    )
    
    result
  }
  
  def EVMRuntime createNestedRuntime(EVMWord gasAvailable) {
    val result = new EVMRuntime(worldState, this)
    
    result.gasAvailable = gasAvailable
    result.memorySize = memorySize
    
    result
  }
  
  def private Pair<Optional<OpCode>, UnsignedByte>[] parseCode(UnsignedByteList code) {
    val result = newArrayOfSize(code.size)
    
    for (var i = 0; i < code.size; i++) {
      val opCode = EVMOperation.getOp(code.get(i))
      result.set(i, Pair.of(Optional.of(opCode), code.get(i)))
      
      for (var j = 0; j < EVMOperation.getParameterCount(opCode); j++) {
        result.set(i + j, Pair.of(Optional.empty, code.get(i)))
      }
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
    try {
      while (true) {
        if (pc >= code.length || pc < 0) {
          return true //reaching the end of the code -> normal halt
        }
        
        val op = code.get(pc).key.orElseThrow[new RuntimeException("invalid op code")]
        if (op === null) {
          throw new RuntimeException("invalid op code")
        }
        
        EVMOperation.executeOp(op, this)
        pc++
      }
    } catch (HaltException h) {
      return true
    } catch (RuntimeException e) {
      return false
    }
  }
  
  def private void cleanup() {
    val unusedGas = currentBlock.gasLimit.sub(gasUsed)
    val refund = EVMWord.min(gasUsed.div(2), refundBalance)
    
    if (parentRuntime === null) {
      patch.addBalance(worldState, callerAddress, unusedGas.add(refund))
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
    val success = _run
    if (success) {
      cleanup
    }
    success
  }
  
  def void executeTransaction(Transaction t) {
    patch.subtractBalance(worldState, t.sender, t.gasLimit)
    
    pc = 0
    memory.clear
    memorySize = EVMWord.ZERO
    stack.clear
    
    fillEnvironmentInfo(t)
    
    gasAvailable = t.gasLimit
    if (gasAvailable.greaterThan(currentBlock.gasLimit)) {
      throw new RuntimeException("Trying to use more gas than the block allows")
    }
    
    patch.clear
    selfDestructSet.clear
    logs.clear
    refundBalance = EVMWord.ZERO
    gasUsed = EVMWord.ZERO
    
    run
  }
  
  def EVMWord popStackItem() {
    if (stack.size == 0) {
      if (parentRuntime === null) {
        throw new RuntimeException("Pop on empty stack")
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
        throw new RuntimeException("Stack index out of bounds")
      } else {
        parentRuntime.getStackItem(n - stack.size)
      }
    } else {
      stack.get(n)
    }
  }
  
  def pushStackItem(EVMWord value) {
    if (stack.size == EVMStack.EVM_MAX_STACK_SIZE) {
      throw new RuntimeException("Push on full stack")
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
      throw new RuntimeException("Out of gas exception")
    }
  }
  
  def void jump(EVMWord targetPC) {
    jump(targetPC.intValue)
  }
  
  def void jump(int targetPC) {
    if (code.get(targetPC).key.isPresent && code.get(targetPC).key.get == OpCode.JUMPDEST) {
      pc = targetPC
    } else {
      throw new RuntimeException("Invalid jump destination")
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
      if (roundedUp.lessThan(s)) s else roundedUp
    }
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
  
  def void setMemoryElement(EVMWord index, Byte value) {
    memory.put(index, value)
  }
  
  //L(n)
  def static EVMWord allButOne64th(EVMWord n) {
    n.sub(n.div(64))
  }
}