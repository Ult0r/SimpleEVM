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

import java.util.List
import org.itemis.types.impl.EVMWord
import java.util.ArrayList

//not using java.util.Stack because of lacking operations
//classical FILO-stack with a maximum depth of 1024 (EVM_MAX_STACK_SIZE)
//elements are 256-bit words
class EVMStack {
  public final static int EVM_MAX_STACK_SIZE = 1024

  // index 0 = top
  private final List<EVMWord> elements = new ArrayList(EVM_MAX_STACK_SIZE)

  def void push(EVMWord word) {
    elements.add(0, word)
  }

  def EVMWord pop() {
    elements.remove(0)
  }

  def void clear() {
    elements.clear
  }

  def EVMWord get(int index) {
    elements.get(index)
  }

  def int size() {
    elements.size
  }
}
