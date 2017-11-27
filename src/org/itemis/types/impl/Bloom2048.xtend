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
import org.itemis.utils.Utils

final class Bloom2048 extends ArbitraryLengthType {
  extension Utils u = new Utils
  
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
  
  def public Bloom2048 addToBloom(byte[] content) {
    val hash = keccak256(content).toUnsignedByteArray
    val newArray = super.toByteArray
    
    val _0 = ((hash.get(0).intValue << 8) + hash.get(1).intValue) % 2048
    val _1 = ((hash.get(2).intValue << 8) + hash.get(3).intValue) % 2048
    val _2 = ((hash.get(4).intValue << 8) + hash.get(5).intValue) % 2048
    
    newArray.set(_0, 1 as byte)
    newArray.set(_1, 1 as byte)
    newArray.set(_2, 1 as byte)
    
    new Bloom2048(newArray)
  }
}
