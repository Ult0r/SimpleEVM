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

class Utils {
	//if n = 0, results in bits 0-7
	//if n = 1, bits 8-15
	//etc.
	def UnsignedByte getNthByteOfInteger(Integer i, int n) {
		new UnsignedByte((i >> (n * 8)).bitwiseAnd(0xFF))
	}
	
	def String toHexString(UnsignedByte b) {
		b.higherNibble.toHex + b.lowerNibble.toHex
	}
	
	//must be between 0 and 15
	def String toHex(UnsignedByte b) {
		switch b.value as int {
			case 0,
			case 1,
			case 2,
			case 3,
			case 4,
			case 5,
			case 6,
			case 7,
			case 8,
			case 9: b.toString()
			case 10: "A"
			case 11: "B"
			case 12: "C"
			case 13: "D"
			case 14: "E"
			case 15: "F"
			default: b.toHexString()
		}
	}
	
	def String toBitString(UnsignedByte b) {
		var result = ""
		for (i : 7..0) {
			result += if (b.getBit(i)) "1" else "0" 
		}
		result
	}
}
