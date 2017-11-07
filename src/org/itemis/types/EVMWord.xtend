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
import java.util.ArrayList

  //TODO replace EVMWord with subclasses (address, hash, etc)
  //TODO make singleton for EVMWord 0
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

  new(long l) {
    setToZero
    value.set(0, new UnsignedByte(l.bitwiseAnd(0x000000FF).byteValue))
    value.set(1, new UnsignedByte((l >> 8).bitwiseAnd(0x000000FF).byteValue))
    value.set(2, new UnsignedByte((l >> 16).bitwiseAnd(0x000000FF).byteValue))
    value.set(3, new UnsignedByte((l >> 24).bitwiseAnd(0x000000FF).byteValue))
    value.set(4, new UnsignedByte((l >> 32).bitwiseAnd(0x000000FF).byteValue))
    value.set(5, new UnsignedByte((l >> 40).bitwiseAnd(0x000000FF).byteValue))
    value.set(6, new UnsignedByte((l >> 48).bitwiseAnd(0x000000FF).byteValue))
    value.set(7, new UnsignedByte((l >> 56).bitwiseAnd(0x000000FF).byteValue))
  }

  new(EVMWord word) {
    for (i : 0 .. 31) {
      value.set(i, new UnsignedByte(word.getNthField(i).value))
    }
  }

  new(UnsignedByte[] array) {
    this(array.map[byteValue])
  }

  new(byte[] array) {
    setToZero
    val length = array.length - 1
    if (array.length != 0) {
      for (i : 0 .. length) {
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

  def static EVMWord fromString(String s) {
    new EVMWord(StaticUtils.fromHex(s))
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

  def UnsignedByte[] toUnsignedByteArray() {
    value
  }

  def byte[] toByteArray() {
    var byte[] result = newByteArrayOfSize(32)
    for (i : 0 .. 31) {
      result.set(i, getNthField(i).byteValue)
    }
    result
  }

  def EVMWord setTo(EVMWord other) {
    for (i : 0 .. 31) {
      this.setNthField(i, other.getNthField(i))
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
    for (i : 0 .. 31) {
      result += this.getNthField(i).toHexString().substring(2)
    }
    result
  }

  def String toHexValueString() {
    var result = ""
    for (i : 31 .. 0) {
      result += this.getNthField(i).toHexString().substring(2)
    }
    while(result.startsWith("0")) {
      result = result.substring(1)
    }

    "0x" + result
  }

  def String toBitString() {
    var result = ""
    for (i : 0 .. 31) {
      result += this.getNthField(i).toBitString()
    }
    result
  }

  def String toAddressString() {
    var result = "0x"
    for (i : 0 .. 19) {
      result += this.getNthField(i).toHexString().substring(2)
    }
    result
  }

  def String toIntString() {
    new BigInteger(reverse.toUnsignedByteArray.dropWhile[it.byteValue == 0].map[toString.substring(2)].join, 16).toString
  }

  //TODO: def int intValue()
  
  // uses 4 bytes from the specified end of the data
  // other bytes are ignored
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

  // uses 63 bit from the specified end of the data
  // other bytes are ignored
  def long toUnsignedLong() {
    var long result = getNthField(7).intValue.bitwiseAnd(0x0FFFFFFF).longValue
    result = result << 8
    result += getNthField(6).longValue
    result = result << 8
    result += getNthField(5).longValue
    result = result << 8
    result += getNthField(4).longValue
    result = result << 8
    result += getNthField(3).longValue
    result = result << 8
    result += getNthField(2).longValue
    result = result << 8
    result += getNthField(1).longValue
    result = result << 8
    result += getNthField(0).longValue
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

  override int hashCode() {
    toHexString.hashCode
  }
  
  def boolean greaterThan(EVMWord other) {
    if (this.isNegative && !other.isNegative) {
      false
    } else if (!this.isNegative && other.isNegative) {
      true
    } else if (this.isNegative && other.isNegative) {
      other.negate.greaterThan(this.negate)
    } else {
      for (var i = 31; i >= 0; i--) {
        if (this.getNthField(i) > other.getNthField(i)) {
          return true
        }
      }
      
      false
    }
  }
  
  def boolean greaterThanEquals(EVMWord other) {
    this.equals(other) || this.greaterThan(other)
  }
  
  def boolean lessThan(EVMWord other) {
    !this.greaterThanEquals(other)
  }
  
  def boolean lessThanEquals(EVMWord other) {
    !this.greaterThan(other)
  }
  
  def static EVMWord min(EVMWord one, EVMWord other) {
    if (one.lessThan(other)) one else other
  }
  
  def static EVMWord max(EVMWord one, EVMWord other) {
    if (one.greaterThan(other)) one else other
  }
  
  def boolean isZero() {
    for (i : 0 .. 31) {
      if(!this.getNthField(i).isZero) {
        return false
      }
    }
    true
  }
  
  def EVMWord reverse() {
    val result = new EVMWord(0)
    
    for (i : 0 .. 31) {
      result.setNthField(i, this.getNthField(31 - i))
    }
    
    result 
  }

  def EVMWord invert() {
    val result = new EVMWord(0)
    
    for (i : 0 .. 31) {
      result.setNthField(i, this.getNthField(i).invert)
    }
    
    result
  }

  // for all mathematical functions:
  // interpreting content as 2-complement
  def BigInteger toBigInteger() {
    new BigInteger(toByteArray.reverseView)
  }
  
  def BigInteger toUnsignedBigInteger() {
    val result = newArrayList
    result.addAll(toByteArray.reverseView)
    result.add(0, new Byte(0x00 as byte))
    new BigInteger(result)
  }
  
  def static EVMWord fromBigInteger(BigInteger i) {
    val List<Byte> l = new ArrayList(i.toByteArray.reverseView)
    if (i.signum == -1) {
      while (l.size != 32) {
        l.add(new Byte(0xFF as byte))
      }
    }
    new EVMWord(l)
  }
  
  def boolean isNegative() {
    toBigInteger.signum == -1
  }

  def EVMWord negate() {
    toBigInteger.negate.fromBigInteger
  }

  def EVMWord inc() {
    toBigInteger.add(BigInteger.ONE).fromBigInteger
  }

  def EVMWord dec() {
    toBigInteger.subtract(BigInteger.ONE).fromBigInteger
  }

  //TODO with int/biginteger and static
  def EVMWord add(EVMWord other) {
    val _this =  toBigInteger
    val _other = other.toBigInteger
    val result = _this.add(_other)
    if (result.bitLength > 255) {
      throw new OverflowException()
    }
    EVMWord.fromBigInteger(result)
  }

  //TODO with int/biginteger and static
  def EVMWord sub(EVMWord other) {
    println(other)
    
    val _this =  toBigInteger
    val _other = other.toBigInteger
    val result = _this.subtract(_other)
    if (result.bitLength > 255) {
      throw new OverflowException()
    }
    EVMWord.fromBigInteger(result)
  }

  //TODO with int/biginteger and static
  def EVMWord mul(EVMWord other) {
    val _this =  toBigInteger
    val _other = other.toBigInteger
    val result = _this.multiply(_other)
    if (result.bitLength > 255) {
      throw new OverflowException()
    }
    EVMWord.fromBigInteger(result)
  }

  //TODO with int/biginteger and static
  def EVMWord div(EVMWord other) {
    val _this =  toBigInteger
    val _other = other.toBigInteger
    val result = _this.divide(_other)
    if (result.bitLength > 255) {
      throw new OverflowException()
    }
    EVMWord.fromBigInteger(result)
  }

  //TODO with int/biginteger and static
  def int log(EVMWord other) {
    if (other.negative || other.zero || other.dec.zero) {
      throw new IllegalArgumentException("log with negative number, 0 or 1")
    }
    
    var result = 0
    var tmp = this
    while (tmp.greaterThan(other)) {
      tmp = tmp.div(other)
      result++
    }
    
    result
  }

  //TODO with int/biginteger and static
  def EVMWord mod(EVMWord other) {
    val _this =  toBigInteger
    val _other = other.toBigInteger
    val result = _this.mod(_other)
    if (result.bitLength > 255) {
      throw new OverflowException()
    }
    EVMWord.fromBigInteger(result)
  }

  //TODO with int/biginteger and static
  def EVMWord divRoundUp(EVMWord other) {
    val _this = toBigInteger
    val _other = other.toBigInteger
    val divRem = _this.divideAndRemainder(_other)
    
    if (divRem.get(1).fromBigInteger.zero) divRem.get(0).fromBigInteger.inc else divRem.get(0).fromBigInteger
  }
  
  def EVMWord xor(EVMWord other) {
    val byte[] bytes = newByteArrayOfSize(32)
    
    for (var i = 0; i < 32; i++) {
      bytes.set(i, this.getNthField(i).byteValue.bitwiseXor(other.getNthField(i).byteValue).byteValue)
    }
    
    new EVMWord(bytes)
  }
  
}
