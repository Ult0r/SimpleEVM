package org.itemis.evm.types

import org.itemis.evm.utils.Utils
import java.util.List

//256-bit / 32-byte int
//[0] contains bits 0-7
//[31] contains bits 248-255
class EVMWord {
	extension Utils u = new Utils()

	private UnsignedByte[] value = newArrayOfSize(32)

	new() {
		setToZero
	}
	
	new(int i) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
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

	def String toHexString() {
		var String result = ""
		for (i : 31 .. 0) {
			result += this.getNthField(i).toHexString()
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
		//TODO
	}
	
	def EVMWord negate() {
		//TODO
	}
	
	def EVMWord inc() {
		add(new EVMWord(1))
	}
	
	def EVMWord add(EVMWord other) {
		//TODO
	}
}
