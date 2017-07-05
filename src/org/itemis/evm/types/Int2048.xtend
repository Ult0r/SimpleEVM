/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/

package org.itemis.evm.types

import java.util.List
import org.itemis.evm.types.exception.OverflowException

//2048-bit / 256-byte int
//[0] contains bits 0-7
//[255] contains bits 2040-2047
class Int2048 {
	private UnsignedByte[] value = newArrayOfSize(255)

	new() {
		setToZero
	}

	new(int i) {
		setToZero
		value.set(0, new UnsignedByte(i.bitwiseAnd(0x000000FF)))
		value.set(1, new UnsignedByte((i >> 8).bitwiseAnd(0x000000FF)))
		value.set(2, new UnsignedByte((i >> 16).bitwiseAnd(0x000000FF)))
		value.set(3, new UnsignedByte((i >> 24).bitwiseAnd(0x000000FF)))
	}

	new(Int2048 other) {
		for (i : 0 .. 255) {
			value.set(i, new UnsignedByte(other.getNthField(i).value))
		}
	}

	new(byte[] array, boolean littleEndian) {
		setToZero
		val length = array.length - 1
		if(littleEndian) {
			for (i : 0 .. length) {
				value.set(i, new UnsignedByte(array.get(i)))
			}
		} else {
			for (i : 255 .. (255 - length)) {
				value.set(255 - i, new UnsignedByte(array.get(i)))
			}
		}
	}

	def Int2048 setToZero() {
		for (i : 0 .. 255) {
			value.set(i, new UnsignedByte(0))
		}
		this
	}

}
