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

import org.itemis.types.impl.EVMWord
import java.util.Map

//256-bit-word-adressed byte array
//volatile and dynamically sized
class EVMMemory {
  private final Map<EVMWord, Byte> elements = newHashMap

  def Byte get(EVMWord index) {
    if (elements.containsKey(index)) {
      elements.get(index)
    } else {
      0 as byte      
    }
  }
  
  def EVMMemory put(EVMWord index, Byte value) {
    elements.put(index, value)
    this
  }

  def EVMMemory remove(EVMWord index) {
    elements.remove(index)
    this
  }
  
  def Map<EVMWord, Byte> elements() {
    elements
  }
  
  def void clear() {
    elements.clear
  }
}
