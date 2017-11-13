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

import org.itemis.evm.EVMOperation
import org.itemis.evm.EVMRuntime
import org.itemis.types.UnsignedByte
import java.util.List
import org.itemis.types.impl.EVMWord
import org.itemis.evm.EVMOperation.FeeClass
import org.itemis.evm.EVMOperation.OpCode
import org.itemis.types.impl.Address

abstract class EnvironmentalInformation {
  def static ADDRESS(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.codeAddress.toEVMWord)
    runtime.addGasCost(FeeClass.BASE)
  }

  def static BALANCE(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val balance = runtime.patch.getBalance(runtime.worldState, new Address(s0))
    runtime.pushStackItem(balance)
    runtime.addGasCost(FeeClass.BALANCE)
  }

  def static ORIGIN(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.originAddress.toEVMWord)
    runtime.addGasCost(FeeClass.BASE)
  }

  def static CALLER(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.callerAddress.toEVMWord)
    runtime.addGasCost(FeeClass.BASE)
  }

  def static CALLVALUE(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.value)
    runtime.addGasCost(FeeClass.BASE)
  }

  def static CALLDATALOAD(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    if(s0.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
      throw new RuntimeException("stack element is larger than 4 byte")
    }
    val _s0 = s0.unsignedIntValue.intValue

    val List<UnsignedByte> bytes = newArrayList
    for (var i = 0; i < 32; i++) {
      bytes.add(try {
        runtime.inputData.get(_s0 + i)
      } catch(Exception e) {
        new UnsignedByte(0x00)
      })
    }

    runtime.pushStackItem(new EVMWord(bytes))
    runtime.addGasCost(FeeClass.VERYLOW)
  }

  def static CALLDATASIZE(EVMRuntime runtime) {
    runtime.pushStackItem(new EVMWord(runtime.inputData.size))
    runtime.addGasCost(FeeClass.BASE)
  }

  def static CALLDATACOPY(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    val s2 = runtime.popStackItem

    if(s1.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
      throw new RuntimeException("stack element is larger than 4 byte")
    }
    val _s1 = s1.unsignedIntValue.intValue

    if(s2.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
      throw new RuntimeException("stack element is larger than 4 byte")
    }
    val _s2 = s2.unsignedIntValue.intValue

    for (var i = 0; i < _s2; i++) {
      runtime.memory.put(s0.add(i), (try {
        runtime.inputData.get(_s1 + i)
      } catch(Exception e) {
        new UnsignedByte(0x00)
      }).byteValue)
    }

    EVMRuntime.calcMemorySize(runtime.memorySize, s0, s2)

    val var_cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.COPY).mul(s2.divRoundUp(32))
    runtime.addGasCost(FeeClass.VERYLOW)
    runtime.addGasCost(var_cost)
  }

  def static CODESIZE(EVMRuntime runtime) {
    runtime.pushStackItem(new EVMWord(runtime.code.size))
    runtime.addGasCost(FeeClass.BASE)
  }

  def static CODECOPY(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    val s2 = runtime.popStackItem

    if(s1.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
      throw new RuntimeException("stack element is larger than 4 byte")
    }
    val _s1 = s1.unsignedIntValue.intValue

    if(s2.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
      throw new RuntimeException("stack element is larger than 4 byte")
    }
    val _s2 = s2.unsignedIntValue.intValue

    for (var i = 0; i < _s2; i++) {
      runtime.memory.put(s0.add(i), EVMOperation.OP_INFO.get(try {
        runtime.code.get(_s1 + i)
      } catch(Exception e) {
        OpCode.STOP
      }).left.byteValue)
    }

    EVMRuntime.calcMemorySize(runtime.memorySize, s0, s2)

    val var_cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.COPY).mul(s2.divRoundUp(32))
    runtime.addGasCost(FeeClass.VERYLOW)
    runtime.addGasCost(var_cost)
  }

  def static GASPRICE(EVMRuntime runtime) {
    runtime.pushStackItem(runtime.gasPrice)
    runtime.addGasCost(FeeClass.BASE)
  }

  def static EXTCODESIZE(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    runtime.pushStackItem(new EVMWord(runtime.worldState.getCodeAt(new Address(s0)).size))
    runtime.addGasCost(FeeClass.EXTCODE)
  }

  def static EXTCODECOPY(EVMRuntime runtime) {
    val s0 = runtime.popStackItem
    val s1 = runtime.popStackItem
    val s2 = runtime.popStackItem
    val s3 = runtime.popStackItem

    if(s2.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
      throw new RuntimeException("stack element is larger than 4 byte")
    }
    val _s2 = s3.unsignedIntValue.intValue

    if(s3.toByteArray.reverseView.dropWhile[it == 0].toList.size > 4) {
      throw new RuntimeException("stack element is larger than 4 byte")
    }
    val _s3 = s3.unsignedIntValue.intValue

    for (var i = 0; i < _s3; i++) {
      runtime.memory.put(s1.add(i), EVMOperation.OP_INFO.get(try {
        runtime.worldState.getCodeAt(new Address(s0)).get(_s2 + i)
      } catch(Exception e) {
        OpCode.STOP
      }).left.byteValue)
    }

    EVMRuntime.calcMemorySize(runtime.memorySize, s1, s3)

    val var_cost = EVMOperation.FEE_SCHEDULE.get(FeeClass.COPY).mul(s2.divRoundUp(32))
    runtime.addGasCost(FeeClass.EXTCODE)
    runtime.addGasCost(var_cost)
  }
}
