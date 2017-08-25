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
import java.math.BigInteger
import java.io.Serializable
import java.io.ObjectOutputStream
import java.io.IOException

//256-bit / 32-byte int
//[0] contains bits 0-7
//[31] contains bits 248-255
class EVMWord implements Serializable {
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
	
	new(UnsignedByte[] array, boolean bigEndian) {
		this(array.map[byteValue], bigEndian)
	}

	new(byte[] array, boolean bigEndian) {
		setToZero
		val length = array.length - 1
		for (i : 0 .. length) {
			if(bigEndian) {
				value.set(i, new UnsignedByte(array.get(i)))
			} else {
				value.set(i, new UnsignedByte(array.get(length - i)))
			}
		}
	}

	def EVMWord setToZero() {
		for (i : 0 .. 31) {
			value.set(i, new UnsignedByte(0))
		}
		this
	}
	
	def static EVMWord fromString(String s) {
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
        unsignedByteArray.add(0, new UnsignedByte((bytes.get(length - 1 - i - 1) << 4) + bytes.get(length - 1 - i)))
      }
      
      i += 2
    }
    
    new EVMWord(unsignedByteArray, false)
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
		  var int result = value.get(n * 2 + 1).intValue
		  result = result << 8
		  result += value.get(n * 2).intValue
		  result
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
	
	def String toAddressString() {
    var result = "0x"
    for (i : 19 .. 0) {
      result += this.getNthField(i).toHexString().substring(2)
    }
    result
	}
	
	def String toTrimmedString() {
    var result = "0x"
    var j = 31
    while (this.getNthField(j).isZero && j > 0) {
      j--
    }
    
    for (i : j .. 0) {
      result += this.getNthField(i).toHexString().substring(2)
    }
    
    result
	}
	
	def String toGoTrimmedString() {
	  var result = toTrimmedString.substring(2)
	  if (result.startsWith("0")) {
	    result = result.substring(1)
	  } 
	  
	  "0x" + result
	}
	
	def String toIntString() {
	  new BigInteger(toString.substring(2), 16).toString
	}

	def byte[] toByteArray(boolean bigEndian) {
		var byte[] result = newByteArrayOfSize(32)
		for (i : 0 .. 31) {
			if(bigEndian) {
				result.set(i, getNthField(i).byteValue)
			} else {
				result.set(i, getNthField(31 - i).byteValue)
			}
		}
		result
	}
	
	//uses 4 bytes from the specified end of the data
	//other bytes are ignored
	def long toUnsignedInt() {
    var long result = getNthField(3).longValue
    result = result << 8
    result += getNthField(2).longValue
    result = result << 8
    result += getNthField(1).longValue
    result = result << 8
    result += getNthField(0).longValue
    result
	}

	override boolean equals(Object other) {
		if (other instanceof EVMWord) {
			var result = true
			for (i : 0 .. 31) {
				result = result && this.getNthField(i).equals(other.getNthField(i))
			}
			result
		} else {
			false
		}
	}
	
	override int hashCode() {
	  toHexString.hashCode
	}
	
	def boolean isZero() {
	  for (i: 0 .. 31) {
	    if (!this.getNthField(i).isZero) {
	      return false
	    }
	  }
	  true
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
	
	def void writeObject(ObjectOutputStream out) throws IOException {
	  out.writeBytes(toString)
	}
}
