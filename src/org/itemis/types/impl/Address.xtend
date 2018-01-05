/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.types.impl

import org.itemis.types.UnsignedByteArray
import org.itemis.types.ArbitraryLengthType

final class Address extends ArbitraryLengthType {
  public static final Address ZERO = new Address()

  new() {
    super(new UnsignedByteArray(20))
  }

  new(byte[] array) {
    super(new UnsignedByteArray(20, array))
  }

  new(UnsignedByteArray array) {
    super(new UnsignedByteArray(20, array))
  }

  new(EVMWord word) {
    super(new UnsignedByteArray(20, word.toUnsignedByteArray))
  }

  def static Address fromString(String s) {
    new Address(UnsignedByteArray.fromString(20, s))
  }
  
  override toEVMWord() {
    new EVMWord(toUnsignedByteArray.reverseView)
  }
}
