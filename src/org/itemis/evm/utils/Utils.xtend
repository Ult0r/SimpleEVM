/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/

package org.itemis.evm.utils

import org.itemis.evm.types.UnsignedByte
import java.util.List
import org.itemis.evm.types.EVMWord

//uses implementations in static utils
class Utils {
	def UnsignedByte[] unsignedByteArrayFromByteArray(byte[] data) {
		StaticUtils.unsignedByteArrayFromByteArray(data)
	}
	
  // if n = 0, results in bits 0-7
  // if n = 1, bits 8-15
  // etc.
  def UnsignedByte getNthByteOfInteger(Integer i, int n) {
    StaticUtils.getNthByteOfInteger(i, n)
  }

  // must be between 0 and 15
  def String toHex(UnsignedByte b) {
    StaticUtils.toHex(b)
  }
  
  def UnsignedByte[] rlp(Object data) {
    StaticUtils.rlp(data)
  }

  // recursive length prefix
  def UnsignedByte[] rlp(UnsignedByte[] data) {
    StaticUtils.rlp(data)
  }

  def UnsignedByte[] rlp(List<UnsignedByte[]> data) {
    StaticUtils.rlp(data)
  }

  def EVMWord keccak256(byte[] input) {
    StaticUtils.keccak256(input)
  }
}
