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

final class Bloom2048 extends ArbitraryLengthType {
  new() {
    super(new UnsignedByteArray(256))
  }
  
  new(int i) {
    super(new UnsignedByteArray(256).setInt(i))
  }
  
  new(byte[] array) {
    super(new UnsignedByteArray(256, array))
  }
  
  new(UnsignedByteArray array) {    
    super(new UnsignedByteArray(256, array))
  }
  
  def static Bloom2048 fromString(String s) {
    new Bloom2048(UnsignedByteArray.fromString(256, s))
  }
}