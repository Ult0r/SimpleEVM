/*******************************************************************************
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
* 
* Contributors:
* Lars Reimers for itemis AG
*******************************************************************************/

package org.itemis.types

import java.security.InvalidParameterException
import org.itemis.utils.Utils

//opposing to the signed java.lang.Byte
class UnsignedByte extends Number implements Comparable<UnsignedByte> {
	extension Utils u = new Utils
	
	private short value = 0 as short
	
	new(byte b) {
		if (b >= 0) {
			value = b
		} else {
			value = b + 256
		}
	}
	
	new(int i) {
		setValue(i)
	}
	
	new(Nibble high, Nibble low) {
	  this(high.value << 4 + low.value)
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
  
  def isZero() {
    return value == 0
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
	
	def String toIntString() {
		value.toString
	}
	
	def String toHexString() {
		"0x" + higherNibble.toHex + lowerNibble.toHex
	}
	
	def String toBitString() {
		var result = ""
		for (i : 7..0) {
			result += if (getBit(i)) "1" else "0" 
		}
		result
	}
	
	def String toASCII() {
		val c = (value.bitwiseAnd(0xFF) as byte) as char
		c.toString
	}
	
	override String toString() {
		toHexString
	}

	def short getValue() {
		value
	}
	
	def void setValue(int v) {
		if (v >= 0 && v <= 255) {
			value = v as short
		} else {
			throw new InvalidParameterException(v + " is not a value between 0 and 255")
		}
	}
	
	def Nibble getHigherNibble() {
		new Nibble(value >> 4)
	}
	
	def Nibble getLowerNibble() {
		new Nibble(value.bitwiseAnd(0x0F))
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
	
	def invert() {
		value = value.bitwiseNot.bitwiseAnd(0x00FF)
	}
	
	def UnsignedByte copy() {
		new UnsignedByte(value)
	}
	
	//overflow = 1
	//no overflow = 0
	def boolean inc() {
		value = (value + 1).bitwiseAnd(0x00FF)
		value == 0
	}
	
	//overflow = 1
	//no overflow = 0
	def boolean add(UnsignedByte other) {
		val newValue = value + other.getValue
		value = newValue.bitwiseAnd(0x00FF)
		newValue > 255
	}
  
}
