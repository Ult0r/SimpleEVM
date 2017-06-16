package org.itemis.evm.types

import java.security.InvalidParameterException

//opposing to the signed java.lang.Byte
class UnsignedByte extends Number implements Comparable<UnsignedByte> {
	private short value = 0 as short
	
	new(int i) {
		if (i >= 0 && i <= 255) {
			value = i as short
		} else {
			throw new InvalidParameterException(i + " is not a value between 0 and 255")
		}
	}
	
	override byteValue() {
		value.byteValue
	}
	
	override compareTo(UnsignedByte other) {
		value.compareTo(other.value)
	}
	
	override doubleValue() {
		value.doubleValue
	}
	
	override equals(Object obj) {
		if (obj instanceof UnsignedByte) {
			value.equals(obj.value)
		} else {
			false
		}
	}

	override floatValue() {
		value.floatValue
	}
	
	override hashCode() {
		value.hashCode
	}
	
	override intValue() {
		value.intValue
	}

	override longValue() {
		value.longValue
	}
	
	override toString() {
		value.toString
	}

	def short getValue() {
		value
	}
	
	def UnsignedByte getHigherNibble() {
		new UnsignedByte(value >> 4)
	}
	
	def UnsignedByte getLowerNibble() {
		new UnsignedByte(value.bitwiseAnd(0x0F))
	}
	
	//true = 1
	//false = 0
	def boolean getBit(int n) {
		if (n >= 0 && n <= 7) {
			(value >> n).bitwiseAnd(0x01) == 1
		} else {
			throw new InvalidParameterException(n + " is not a value between 0 and 7")
		}
	}
}
