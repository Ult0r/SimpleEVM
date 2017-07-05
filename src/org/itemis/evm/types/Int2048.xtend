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

	// n must be between (including) 0 and 255
	def UnsignedByte getNthField(Integer n) {
		if(n >= 0 && n <= 255) {
			value.get(n)
		} else {
			throw new IllegalArgumentException(n + " is not between 0 and 255")
		}
	}

	// n must be between (including) 0 and 127
	def int getNth16BitField(Integer n) {
		if(n >= 0 && n <= 127) {
			value.get(n * 2 + 1).intValue * 256 + value.get(n * 2).intValue
		} else {
			throw new IllegalArgumentException(n + " is not between 0 and 127")
		}
	}

	def List<Integer> convertTo16BitFieldList() {
		var List<Integer> result = newArrayList()
		for (i : 0 .. 127) {
			result.add(getNth16BitField(i))
		}
		result
	}

	def UnsignedByte[] toByteArray() {
		value
	}

	def Int2048 setTo(Int2048 other) {
		for (i : 0 .. 255) {
			this.setNthField(i, other.getNthField(i).copy)
		}
		this
	}

	def Int2048 setNthField(Integer n, int newValue) {
		setNthField(n, newValue as short)
	}

	def Int2048 setNthField(Integer n, short newValue) {
		value.get(n).setValue(newValue)
		this
	}

	def Int2048 setNthField(Integer n, UnsignedByte newValue) {
		value.set(n, newValue)
		this
	}

	override String toString() {
		toHexString
	}

	def String toHexString() {
		var result = "0x"
		for (i : 255 .. 0) {
			result += this.getNthField(i).toHexString().substring(2)
		}
		result
	}

	def String toBitString() {
		var result = ""
		for (i : 255 .. 0) {
			result += this.getNthField(i).toBitString()
		}
		result
	}

}
