package org.itemis.evm.op

import org.itemis.evm.EVMOperation
import org.itemis.evm.EVMRuntime
import org.itemis.types.UnsignedByte
import java.util.List
import org.itemis.types.EVMWord
import org.itemis.evm.EVMOperation.FeeClass
import org.itemis.evm.EVMOperation.OpCode

abstract class EnvironmentalInformation {
  def static ADDRESS(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.codeAddress)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE))
  }

  def static BALANCE(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val balance = runtime.patch.getBalance(runtime.worldState, s0)
    runtime.pushStackItem(balance)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BALANCE))
  }

  def static ORIGIN(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.originAddress)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE))
  }

  def static CALLER(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.callerAddress)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE))
  }

  def static CALLVALUE(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.value)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE))
  }

  def static CALLDATALOAD(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    if(s0.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
      throw new RuntimeException("stack element is larger than 4 byte")
    }
    val _s0 = s0.toUnsignedInt.intValue

    val List<UnsignedByte> bytes = newArrayList
    for (var i = 0; i < 32; i++) {
      bytes.add(try {
        runtime.inputData.get(_s0 + i)
      } catch(Exception e) {
        new UnsignedByte(0x00)
      })
    }

    runtime.pushStackItem(new EVMWord(bytes))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW))
  }

  def static CALLDATASIZE(EVMRuntime runtime) {
    runtime.pushStackItem(new EVMWord(runtime.inputData.size))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE))
  }

  def static CALLDATACOPY(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    val s2 = runtime.popStackItem

    if(s1.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
      throw new RuntimeException("stack element is larger than 4 byte")
    }
    val _s1 = s1.toUnsignedInt.intValue

    if(s2.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
      throw new RuntimeException("stack element is larger than 4 byte")
    }
    val _s2 = s2.toUnsignedInt.intValue

    for (var i = 0; i < _s2; i++) {
      runtime.memory.put(s0.add(new EVMWord(i)), (try {
        runtime.inputData.get(_s1 + i)
      } catch(Exception e) {
        new UnsignedByte(0x00)
      }).byteValue)
    }

    EVMRuntime.calcMemorySize(runtime.memorySize, s0, s2)

    val var_cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.COPY).mul(s2.divRoundUp(new EVMWord(32)))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW).add(var_cost))
  }

  def static CODESIZE(EVMRuntime runtime) {
    runtime.pushStackItem(new EVMWord(runtime.code.size))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE))
  }

  def static CODECOPY(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    val s2 = runtime.popStackItem

    if(s1.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
      throw new RuntimeException("stack element is larger than 4 byte")
    }
    val _s1 = s1.toUnsignedInt.intValue

    if(s2.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
      throw new RuntimeException("stack element is larger than 4 byte")
    }
    val _s2 = s2.toUnsignedInt.intValue

    for (var i = 0; i < _s2; i++) {
      runtime.memory.put(s0.add(new EVMWord(i)), EVMOperation.OP_INFO.get(try {
        runtime.code.get(_s1 + i)
      } catch(Exception e) {
        OpCode.STOP
      }).left.byteValue)
    }

    EVMRuntime.calcMemorySize(runtime.memorySize, s0, s2)

    val var_cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.COPY).mul(s2.divRoundUp(new EVMWord(32)))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.VERYLOW).add(var_cost))
  }

  def static GASPRICE(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.gasPrice)
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.BASE))
  }

  def static EXTCODESIZE(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    runtime.pushStackItem(new EVMWord(runtime.worldState.getCodeAt(s0).size))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.EXTCODE))
  }

  def static EXTCODECOPY(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    val s2 = runtime.popStackItem
    val s3 = runtime.popStackItem

    if(s2.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
      throw new RuntimeException("stack element is larger than 4 byte")
    }
    val _s2 = s3.toUnsignedInt.intValue

    if(s3.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
      throw new RuntimeException("stack element is larger than 4 byte")
    }
    val _s3 = s3.toUnsignedInt.intValue

    for (var i = 0; i < _s3; i++) {
      runtime.memory.put(s1.add(new EVMWord(i)), EVMOperation.OP_INFO.get(try {
        runtime.worldState.getCodeAt(s0).get(_s2 + i)
      } catch(Exception e) {
        OpCode.STOP
      }).left.byteValue)
    }

    EVMRuntime.calcMemorySize(runtime.memorySize, s1, s3)

    val var_cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.COPY).mul(s2.divRoundUp(new EVMWord(32)))
    runtime.addGasCost(EVMOperation.FEE_SCHEDULE.get(FeeClass.EXTCODE).add(var_cost))
  }
}
