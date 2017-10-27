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

final class EVMRuntime {
  @Accessors private EVMWord gasAvailable
  @Accessors private int pc
  @Accessors private final EVMMemory memory = new EVMMemory()
  @Accessors private EVMWord memorySize = new EVMWord(0)
  @Accessors private final EVMStack stack = new EVMStack()
  @Accessors private final EVMStorage storage = new EVMStorage()
  
  @Accessors private EVMWord codeAddress       //Ia
  @Accessors private EVMWord originAddress     //Io
  @Accessors private EVMWord gasPrice          //Ip
  @Accessors private UnsignedByte[] inputData  //Id
  @Accessors private EVMWord callerAddress     //Is
  @Accessors private EVMWord value             //Iv
  @Accessors private OpCode[] code             //Ib
  @Accessors private Block currentBlock        //IH
  @Accessors private EVMWord depth             //Ie
  
  @Accessors private final WorldState worldState
  @Accessors private final List<Patch> patches = newArrayList
  
  new(WorldState ws) {
    worldState = ws
  }
  
  def void executeTransaction(Transaction t) {
    var gasUsed = new EVMWord(0)
    //TODO
    //get code
    //stop on finding STOP
    //apply patches
    //clean up runtime
  }
  
  def void executeOperation(EVMOperation op) {
    //TODO
    //add patch to list
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