package org.itemis.evm

class Utils {
	//if n = 0, results in bits 0-7
	//if n = 1, bits 8-15
	//etc.
	def Byte getNthByteOfInteger(Integer i, byte n) {
		((i >> (n * 8)) % 255).byteValue
	}
	
	def String toHexString(Byte b) {
		val lowerHalf = (b % 16) as byte
		val upperHalf = (b / 16) as byte
		upperHalf.toHex + lowerHalf.toHex
	}
	
	//must be between 0 and 15
	def String toHex(Byte b) {
		switch b {
			case 0..9: b.toString()
			case 10: "A"
			case 11: "B"
			case 12: "C"
			case 13: "D"
			case 14: "E"
			case 15: "F"
		}
	}
	
	def String toBitString(Byte b) {
		var result = ""
		for (i : 7..0) {
			result += (b >> i).toString()	
		}
		result
	}
}