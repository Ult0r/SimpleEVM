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

final class Hash256 extends ArbitraryLengthType {
  public static final Hash256 ZERO = new Hash256()

  new() {
    super(new UnsignedByteArray(32))
  }

  new(byte[] array) {
    super(new UnsignedByteArray(32, array))
  }

  new(UnsignedByte[] array) {
    super(new UnsignedByteArray(32, array))
  }

  new(UnsignedByteArray array) {
    super(new UnsignedByteArray(32, array))
  }

  def static Hash256 fromString(String s) {
    new Hash256(UnsignedByteArray.fromString(32, s))
  }
}
