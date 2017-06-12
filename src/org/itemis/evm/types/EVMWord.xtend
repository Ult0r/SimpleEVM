package org.itemis.evm.types

import org.itemis.evm.Utils

//256-bit / 32-byte int
//[0] contains bits 0-7
//[31] contains bits 248-255
class EVMWord {
	extension Utils u = new Utils()
	
	private Byte[] value = newArrayOfSize(32)

	new() {
		setToZero
	}

	def setToZero() {
		for (i : 0 .. 31) {
			value.set(i, 0 as byte)
		}
	}

	// n must be between (including) 0 and 7
	def Byte getNthField(Integer n) {
		value.get(n)
	}
	
	def Byte[] toByteArray() {
		value
	}

	def setNthField(Integer n, Byte newValue) {
		value.set(n, newValue)
	}

	def String toHexString() {
		var String result = ""
		for (i: 31 .. 0) {
			result += this.getNthField(i).toHexString()
		}
		result
	}
	
	def String toBitString() {
		var result = ""
		for (i: 31 .. 0) {
			result += this.getNthField(i).toBitString()
		}
		result
	}
}
