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

abstract class PushOperations {
  def static PUSHN(int n, EVMRuntime runtime) {
    var bytes = newByteArrayOfSize(32)

    for (var i = 0; i < 32; i++) {
      if (i < n) {
        bytes.set(n - i - 1, runtime.code.get(runtime.pc + i + 1).value.byteValue)
      } else {
        bytes.set(i, 0 as byte)
      }
    }
    
    runtime.pushStackItem(new EVMWord(bytes))
    runtime.addGasCost(FeeClass.VERYLOW)
  }
}
