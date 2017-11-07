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
import org.itemis.types.UnsignedByteList
import org.itemis.blockchain.BlockchainData
import java.util.Set

final class EVMRuntime {
  @Accessors private final WorldState worldState
  
  @Accessors private int pc = 0
  @Accessors private EVMMemory memory = new EVMMemory()
  @Accessors private EVMWord memorySize = new EVMWord(0)
  private EVMStack stack = new EVMStack()
  
  @Accessors private EVMWord codeAddress                         //Ia
  @Accessors private EVMWord originAddress                       //Io
  @Accessors private EVMWord gasPrice                            //Ip
  @Accessors private UnsignedByte[] inputData                    //Id
  @Accessors private EVMWord callerAddress                       //Is
  @Accessors private EVMWord value                               //Iv
  @Accessors private Pair<Optional<OpCode>, UnsignedByte>[] code //Ib
  @Accessors private Block currentBlock                          //IH
  @Accessors private EVMWord depth                               //Ie
  
  @Accessors private Patch patch = new Patch()
  @Accessors private Set<EVMWord> selfDestructSet = newHashSet
  @Accessors private List<EVMLog> logs = newArrayList
  @Accessors private EVMWord refundBalance = new EVMWord(0)
  private EVMWord gasUsed = new EVMWord(0)
  
  new(WorldState ws) {
    worldState = ws
  }
  
  def EVMRuntime createNestedRuntime(EVMWord value, byte[] code) {
    val result = new EVMRuntime(worldState)
    
    result.fillEnvironmentInfo(
      null, //TODO: new account address
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
      new EVMWord(0)
    )
  }
  
  def void fillEnvironmentInfo(
    EVMWord codeAddress,
    EVMWord originAddress,
    EVMWord gasPrice,
    UnsignedByte[] inputData,
    EVMWord callerAddress,
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
    } catch (RuntimeException e) {
      return false
    }
  }
  
  def private void cleanup() {
    val unusedGas = currentBlock.gasLimit.sub(gasUsed)
    val refund = EVMWord.min(gasUsed.div(new EVMWord(2)), refundBalance)
    
    patch.addBalance(worldState, callerAddress, unusedGas.add(refund))
    patch.applyChanges(worldState)
    
    worldState.incExecutedTransaction
  }
  
  def boolean run() {
    //TODO: validate logs
    val success = _run
    if (success /*&& logs valid */) {
      cleanup
    }
    success
  }
  
  def void executeTransaction(Transaction t) {
    patch.subtractBalance(worldState, t.sender, t.gasLimit)
    
    pc = 0
    memory.clear
    memorySize = new EVMWord(0)
    stack.clear
    
    fillEnvironmentInfo(t)
    
    patch.clear
    selfDestructSet.clear
    logs.clear
    refundBalance = new EVMWord(0)
    gasUsed = new EVMWord(0)
    
    run
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
  
  //TODO: change parameter to FeeClass
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