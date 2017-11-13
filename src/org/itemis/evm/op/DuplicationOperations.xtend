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

abstract class DuplicationOperations {
  def static DUPN(int n, EVMRuntime runtime) {

    runtime.pushStackItem(runtime.getStackItem(n - 1))
    runtime.addGasCost(FeeClass.VERYLOW)
  }
}
