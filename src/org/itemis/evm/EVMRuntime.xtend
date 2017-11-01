package org.itemis.evm

import org.itemis.types.EVMWord
import org.itemis.blockchain.Transaction
import org.eclipse.xtend.lib.annotations.Accessors
import org.itemis.blockchain.WorldState
import java.util.List
import org.itemis.evm.utils.Patch
import org.itemis.types.UnsignedByte
import org.itemis.evm.EVMOperation.OpCode
import org.itemis.blockchain.Block
import java.util.Optional

final class EVMRuntime {
  @Accessors private EVMWord gasAvailable
  @Accessors private int pc
  @Accessors private EVMMemory memory
  @Accessors private EVMWord memorySize
  private EVMStack stack
  
  @Accessors private EVMWord codeAddress                         //Ia
  @Accessors private EVMWord originAddress                       //Io
  @Accessors private EVMWord gasPrice                            //Ip
  @Accessors private UnsignedByte[] inputData                    //Id
  @Accessors private EVMWord callerAddress                       //Is
  @Accessors private EVMWord value                               //Iv
  @Accessors private Pair<Optional<OpCode>, UnsignedByte>[] code //Ib
  @Accessors private Block currentBlock                          //IH
  @Accessors private EVMWord depth                               //Ie
  
  @Accessors private final WorldState worldState
  @Accessors private Patch patch
  
  @Accessors private List<EVMWord> selfdestructSet
  @Accessors private List<EVMLog> logs
  @Accessors private EVMWord refundBalance
  private EVMWord gasUsed
  
  new(WorldState ws) {
    worldState = ws
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
    } catch (RuntimeException e) {
      return false
    }
  }
  
  def private void cleanup() {
    //TODO
  }
  
  def boolean run() {
    val success = _run
    if (success) {
      cleanup
    }
    success
  }
  
  def void executeTransaction(Transaction t) {
    //TODO
    //sets private fields
    //apply patches
    //clean up runtime
  }
  
  def EVMWord popStackItem() {
    if (stack.size == 0) {
      throw new RuntimeException("Pop on empty stack")
    }
    stack.pop
  }
  
  def EVMWord getStackItem(int n) {
    if (stack.size <= n) {
      throw new RuntimeException("Stack index out of bounds")
    }
    stack.get(n)
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
  
  def void addGasCost(EVMWord gasAmount) {
    gasUsed = gasUsed.add(gasAmount)
    if (gasUsed.greaterThan(currentBlock.gasLimit)) {
      throw new RuntimeException("Out of gas exception")
    }
  }
  
  def void jump(EVMWord targetPC) {
    jump(targetPC.toUnsignedInt.intValue)
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
      val divRes = sumRes.div(new EVMWord(32))
      val roundedUp = if (divRes.mul(new EVMWord(32)).equals(sumRes)) {
        divRes
      } else {
        divRes.inc
      }
      if (roundedUp.lessThan(s)) s else roundedUp
    }
  }
}