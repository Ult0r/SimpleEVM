package org.itemis.evm.op

import org.itemis.evm.EVMOperation
import org.itemis.evm.EVMRuntime
import org.itemis.evm.utils.Patch
import org.itemis.types.UnsignedByte
import java.util.List
import org.itemis.types.EVMWord

abstract class EnvironmentalInformation {
  static class ADDRESS extends EVMOperation {
    override execute(EVMRuntime runtime) {
      runtime.stack.push(runtime.codeAddress)
      Pair.of(FEE_SCHEDULE.get(FeeClass.BASE), null)
    }
  }
  
  static class BALANCE extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val balance = Patch.getBalance(runtime.worldState, runtime.patches, s0)
      runtime.stack.push(balance)
      Pair.of(FEE_SCHEDULE.get(FeeClass.BALANCE), null)
    }
  }
  
  static class ORIGIN extends EVMOperation {
    override execute(EVMRuntime runtime) {
      runtime.stack.push(runtime.originAddress)
      Pair.of(FEE_SCHEDULE.get(FeeClass.BASE), null)
    }
  }
  
  static class CALLER extends EVMOperation {
    override execute(EVMRuntime runtime) {
      runtime.stack.push(runtime.callerAddress)
      Pair.of(FEE_SCHEDULE.get(FeeClass.BASE), null)
    }
  }
  
  static class CALLVALUE extends EVMOperation {
    override execute(EVMRuntime runtime) {
      runtime.stack.push(runtime.value)
      Pair.of(FEE_SCHEDULE.get(FeeClass.BASE), null)
    }
  }
  
  static class CALLDATALOAD extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      if (s0.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
        throw new RuntimeException("stack element is larger than 4 byte")
      }
      val _s0 = s0.toUnsignedInt.intValue
      
      val List<UnsignedByte> bytes = newArrayList
      for (var i = 0; i < 32; i++) {
        bytes.add(try {
          runtime.inputData.get(_s0 + i)
        } catch (Exception e) {
          new UnsignedByte(0x00)
        })
      }
            
      runtime.stack.push(new EVMWord(bytes))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW), null)
    }
  }
  
  static class CALLDATASIZE extends EVMOperation {
    override execute(EVMRuntime runtime) {
      runtime.stack.push(new EVMWord(runtime.inputData.size))
      Pair.of(FEE_SCHEDULE.get(FeeClass.BASE), null)
    }
  }
  
  static class CALLDATACOPY extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      val s2 = runtime.stack.pop
      
      if (s1.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
        throw new RuntimeException("stack element is larger than 4 byte")
      }
      val _s1 = s1.toUnsignedInt.intValue
      
      if (s2.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
        throw new RuntimeException("stack element is larger than 4 byte")
      }
      val _s2 = s2.toUnsignedInt.intValue
      
      for (var i = 0; i < _s2; i++) {
        runtime.memory.put(s0.add(new EVMWord(i)), (try {
          runtime.inputData.get(_s1 + i)
        } catch (Exception e) {
          new UnsignedByte(0x00)
        }).byteValue)
      }
      
      EVMRuntime.calcMemorySize(runtime.memorySize, s0, s2)
      
      val var_cost = FEE_SCHEDULE.get(FeeClass.COPY).mul(s2.divRoundUp(new EVMWord(32)))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW).add(var_cost), null)
    }
  }
  
  static class CODESIZE extends EVMOperation {
    override execute(EVMRuntime runtime) {
      runtime.stack.push(new EVMWord(runtime.code.size))
      Pair.of(FEE_SCHEDULE.get(FeeClass.BASE), null)
    }
  }
  
  static class CODECOPY extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      val s2 = runtime.stack.pop
      
      if (s1.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
        throw new RuntimeException("stack element is larger than 4 byte")
      }
      val _s1 = s1.toUnsignedInt.intValue
      
      if (s2.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
        throw new RuntimeException("stack element is larger than 4 byte")
      }
      val _s2 = s2.toUnsignedInt.intValue
      
      for (var i = 0; i < _s2; i++) {
        runtime.memory.put(s0.add(new EVMWord(i)), OP_VALUES.get(try {
          runtime.code.get(_s1 + i)
        } catch (Exception e) {
          OpCode.STOP
        }).left.byteValue)
      }
      
      EVMRuntime.calcMemorySize(runtime.memorySize, s0, s2)
      
      val var_cost = FEE_SCHEDULE.get(FeeClass.COPY).mul(s2.divRoundUp(new EVMWord(32)))
      Pair.of(FEE_SCHEDULE.get(FeeClass.VERYLOW).add(var_cost), null)
    }
  }
  
  static class GASPRICE extends EVMOperation {
    override execute(EVMRuntime runtime) {
      runtime.stack.push(runtime.gasPrice)
      Pair.of(FEE_SCHEDULE.get(FeeClass.BASE), null)
    }
  }
  
  static class EXTCODESIZE extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      runtime.stack.push(new EVMWord(runtime.worldState.getCodeAt(s0).size))
      Pair.of(FEE_SCHEDULE.get(FeeClass.EXTCODE), null)
    }
  }
  
  static class EXTCODECOPY extends EVMOperation {
    override execute(EVMRuntime runtime) {
      val s0 = runtime.stack.pop
      val s1 = runtime.stack.pop
      val s2 = runtime.stack.pop
      val s3 = runtime.stack.pop
      
      if (s2.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
        throw new RuntimeException("stack element is larger than 4 byte")
      }
      val _s2 = s3.toUnsignedInt.intValue
      
      if (s3.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
        throw new RuntimeException("stack element is larger than 4 byte")
      }
      val _s3 = s3.toUnsignedInt.intValue
      
      for (var i = 0; i < _s3; i++) {
        runtime.memory.put(s1.add(new EVMWord(i)), OP_VALUES.get(try {
          runtime.worldState.getCodeAt(s0).get(_s2 + i)
        } catch (Exception e) {
          OpCode.STOP
        }).left.byteValue)
      }
      
      EVMRuntime.calcMemorySize(runtime.memorySize, s1, s3)
      
      val var_cost = FEE_SCHEDULE.get(FeeClass.COPY).mul(s2.divRoundUp(new EVMWord(32)))
      Pair.of(FEE_SCHEDULE.get(FeeClass.EXTCODE).add(var_cost), null)
    }
  }
}