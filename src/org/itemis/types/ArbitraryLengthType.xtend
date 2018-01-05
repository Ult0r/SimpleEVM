/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.types

import org.itemis.types.impl.EVMWord

abstract class ArbitraryLengthType {
  private final UnsignedByteArray array

  new(UnsignedByteArray array) {
    this.array = array
  }

  def byte[] toByteArray() {
    array.toByteArray
  }

  def UnsignedByte[] toUnsignedByteArray() {
    array.toUnsignedByteArray
  }

  override String toString() {
    toHexString
  }

  def String toHexString() {
    array.toHexString
  }

  def EVMWord toEVMWord() {
    new EVMWord(new UnsignedByteArray(32, array))
  }

  override boolean equals(Object other) {
    if(other instanceof ArbitraryLengthType) {
      array.equals(other.array)
    } else {
      false
    }
  }
  
  override int hashCode() {
    array.hashCode
  }
}
