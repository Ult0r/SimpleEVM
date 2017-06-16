package org.itemis.evm

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
	def String toHex(Byte b) {
		var int _b = b.normalizeNegativeByte
		switch _b {
			case 0 as byte,
			case 1 as byte,
			case 2 as byte,
			case 3 as byte,
			case 4 as byte,
			case 5 as byte,
			case 6 as byte,
			case 7 as byte,
			case 8 as byte,
			case 9 as byte: b.toString()
			case 10 as byte: "A"
			case 11 as byte: "B"
			case 12 as byte: "C"
			case 13 as byte: "D"
			case 14 as byte: "E"
			case 15 as byte: "F"
			default: b.toHexString()
		}
	}
	
	def String toBitString(Byte b) {
		var int _b = b.normalizeNegativeByte
		var result = ""
		for (i : 7..0) {
			result += ((_b >> i).bitwiseAnd(1)).toString()
		}
		result
	}
}