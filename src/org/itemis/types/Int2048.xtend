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

import java.util.List
import org.itemis.evm.OverflowException
import org.itemis.utils.StaticUtils

//2048-bit / 256-byte int
//[0] contains bits 0-7
//[255] contains bits 2040-2047
class Int2048 {
	private UnsignedByte[] value = newArrayOfSize(256)

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
  
  new(UnsignedByte[] array, boolean bigEndian) {
    this(array.map[byteValue], bigEndian)
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
  
  def static Int2048 fromString(String s) {
    var data = s
    if (s.startsWith("0x")) {
      data = s.substring(2)
    }
    
    var bytes = StaticUtils.fromHex(data).map[intValue]
    val length = bytes.size
    
    var unsignedByteArray = newArrayList
    var i = 0
    while (i < length) {
      if (i == (length - 1)) {
        unsignedByteArray.add(0, new UnsignedByte(bytes.get(0)))
      } else {
        unsignedByteArray.add(0, new UnsignedByte((bytes.get(length - 1 - i) << 4) + bytes.get(length - 1 - i - 1)))
      }
      
      i += 2
    }
    
    new Int2048(unsignedByteArray, false)
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

	override boolean equals(Object other) {
		if(other instanceof Int2048) {
			var result = true
			for (i : 0 .. 255) {
				result = result && this.getNthField(i).equals(other.getNthField(i))
			}
			result
		} else {
			false
		}
	}

	def Int2048 invert() {
		for (i : 0 .. 255) {
			this.getNthField(i).invert
		}
		this
	}

	def Int2048 copy() {
		var result = new Int2048()
		for (i : 0 .. 255) {
			result.setNthField(i, this.getNthField(i).copy())
		}
		result
	}

	// for all mathematical functions:
	// interpreting content as 2-complement
	def boolean isNegative() {
		(getNthField(255).value >> 7) == 1
	}

	def Int2048 negate() {
		invert.inc
	}

	def Int2048 inc() {
		add(new Int2048(1))
	}

	def Int2048 dec() {
		sub(new Int2048(1))
	}

	def Int2048 add(Int2048 other) {
		if(this.isNegative && other.isNegative) {
			this.negate.add(other.copy.negate).negate
		} else {
			val wasNegative = this.isNegative
			var overflow = false
			for (i : 0 .. 255) {
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

	def Int2048 sub(Int2048 other) {
		add(other.negate)
	}
  
}
