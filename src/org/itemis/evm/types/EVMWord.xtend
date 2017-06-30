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

//256-bit / 32-byte int
//[0] contains bits 0-7
//[31] contains bits 248-255
class EVMWord {
	private UnsignedByte[] value = newArrayOfSize(32)

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

	new(EVMWord word) {
		for (i : 0 .. 31) {
			value.set(i, new UnsignedByte(word.getNthField(i).value))
		}
	}

	new(byte[] array, boolean littleEndian) {
		setToZero
		if(littleEndian) {
			for (i : 0 .. array.length) {
				value.set(i, new UnsignedByte(array.get(i)))
			}
		} else {
			for (i : 31 .. (31 - array.length + 1)) {
				value.set(i, new UnsignedByte(array.get(i)))
			}
		}
	}

	def EVMWord setToZero() {
		for (i : 0 .. 31) {
			value.set(i, new UnsignedByte(0))
		}
		this
	}

	// n must be between (including) 0 and 31
	def UnsignedByte getNthField(Integer n) {
		if(n >= 0 && n <= 31) {
			value.get(n)
		} else {
			throw new IllegalArgumentException(n + " is not between 0 and 31")
		}
	}

	// n must be between (including) 0 and 15
	def int getNth16BitField(Integer n) {
		if(n >= 0 && n <= 16) {
			value.get(n * 2 + 1).intValue * 256 + value.get(n * 2).intValue
		} else {
			throw new IllegalArgumentException(n + " is not between 0 and 16")
		}
	}

	def List<Integer> convertTo16BitFieldList() {
		var List<Integer> result = newArrayList()
		for (i : 0 .. 15) {
			result.add(getNth16BitField(i))
		}
		result
	}

	def UnsignedByte[] toByteArray() {
		value
	}

	def EVMWord setTo(EVMWord other) {
		for (i : 0 .. 31) {
			this.setNthField(i, other.getNthField(i).copy)
		}
		this
	}

	def EVMWord setNthField(Integer n, int newValue) {
		setNthField(n, newValue as short)
	}

	def EVMWord setNthField(Integer n, short newValue) {
		value.get(n).setValue(newValue)
		this
	}

	def EVMWord setNthField(Integer n, UnsignedByte newValue) {
		value.set(n, newValue)
		this
	}

	override String toString() {
		toHexString
	}

	def String toHexString() {
		var result = "0x"
		for (i : 31 .. 0) {
			result += this.getNthField(i).toHexString().substring(2)
		}
		result
	}

	def String toBitString() {
		var result = ""
		for (i : 31 .. 0) {
			result += this.getNthField(i).toBitString()
		}
		result
	}

	override boolean equals(Object other) {
		if(other instanceof EVMWord) {
			var result = true
			for (i : 0 .. 31) {
				result = result && this.getNthField(i).equals(other.getNthField(i))
			}
			result
		} else {
			false
		}
	}

	def EVMWord invert() {
		for (i : 0 .. 31) {
			this.getNthField(i).invert
		}
		this
	}

	def EVMWord copy() {
		var result = new EVMWord()
		for (i : 0 .. 31) {
			result.setNthField(i, this.getNthField(i).copy())
		}
		result
	}

	// for all mathematical functions:
	// interpreting content as 2-complement
	def boolean isNegative() {
		(getNthField(31).value >> 7) == 1
	}

	def EVMWord negate() {
		invert.inc
	}

	def EVMWord inc() {
		add(new EVMWord(1))
	}

	def EVMWord dec() {
		sub(new EVMWord(1))
	}

	def EVMWord add(EVMWord other) {
		if(this.isNegative && other.isNegative) {
			this.negate.add(other.copy.negate).negate
		} else {
			val wasNegative = this.isNegative
			var overflow = false
			for (i : 0 .. 31) {
				if(overflow) {
					overflow = this.getNthField(i).inc || this.getNthField(i).add(other.getNthField(i))
				} else {
					overflow = this.getNthField(i).add(other.getNthField(i))
				}
			}
			if(!wasNegative && !other.isNegative && this.isNegative) {
				throw new OverflowException()
			}
			this
		}
	}

	def EVMWord sub(EVMWord other) {
		add(other.negate)
	}
}
