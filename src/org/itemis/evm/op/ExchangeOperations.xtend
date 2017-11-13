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
import org.itemis.evm.EVMOperation.FeeClass

abstract class ExchangeOperations {
  def static SWAPN(int n, EVMRuntime runtime) {
    val head = runtime.popStackItem
    val stackElements = newArrayList
    for (var i = 0; i < (n - 1); i++) {
      stackElements.add(runtime.popStackItem)
    }
    val tail = runtime.popStackItem

    runtime.pushStackItem(head)
    for (e : stackElements.reverseView) {
      runtime.pushStackItem(e)
    }
    runtime.pushStackItem(tail)

    runtime.addGasCost(FeeClass.VERYLOW)
  }
}
