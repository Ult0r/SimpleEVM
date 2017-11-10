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

import org.itemis.types.EVMWord
import java.util.Map

//256-bit-word-adressed byte array
//volatile and dynamically sized
class EVMMemory {
  private final Map<EVMWord, Byte> elements = newHashMap
  private EVMWord size = EVMWord.ZERO
  
  def Byte get(EVMWord index) {
    elements.get(index)
  }

  def EVMMemory put(EVMWord index, Byte value) {
    size = size.inc
    elements.put(index, value)
    this
  }
  
  def EVMMemory remove(EVMWord index) {
    size = size.dec
    elements.remove(index)
    this
  }

  def EVMWord size() {
    size
  }
  
  def void clear() {
    size = EVMWord.ZERO
    elements.clear
  }
}
