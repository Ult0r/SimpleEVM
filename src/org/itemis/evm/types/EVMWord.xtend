package org.itemis.evm.types

import org.itemis.evm.Utils

//256-bit / 32-byte int
//[0] contains bits 0-7
//[31] contains bits 248-255
class EVMWord {
	extension Utils u = new Utils()
	
	private UnsignedByte[] value = newArrayOfSize(32)

	new() {
		setToZero
	}

	def EVMWord setToZero() {
		for (i : 0 .. 31) {
			value.set(i, new UnsignedByte(0))
		}
		this
	}

	// n must be between (including) 0 and 31
	def UnsignedByte getNthField(Integer n) {
		value.get(n)
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
