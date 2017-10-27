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

  new(UnsignedByte[] array) {
    this(array.map[byteValue])
  }

  new(byte[] array) {
    setToZero
    val length = array.length - 1
    for (i : 255 .. (255 - length)) {
      value.set(255 - i, new UnsignedByte(array.get(i)))
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
    if(s.startsWith("0x")) {
      data = s.substring(2)
    }

    new Int2048(StaticUtils.fromHex(data))
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

  def UnsignedByte[] toUnsignedByteArray() {
    value
  }

  def byte[] toByteArray() {
    var byte[] result = newByteArrayOfSize(256)
    for (i : 0 .. 255) {
      result.set(i, getNthField(i).byteValue)
    }
    result
  }

  def Int2048 setTo(Int2048 other) {
    for (i : 0 .. 255) {
      this.setNthField(i, other.getNthField(i))
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
  
  def Int2048 reverse() {
    val result = new Int2048(0)
    
    for (i : 0 .. 255) {
      result.setNthField(i, this.getNthField(31 - i))
    }
    
    result 
  }

  def Int2048 invert() {
    val result = new Int2048(0)
    
    for (i : 0 .. 255) {
      result.setNthField(i, this.getNthField(i).invert)
    }
    
    result
  }

  // for all mathematical functions:
  // interpreting content as 2-complement
  def BigInteger toBigInteger() {
    new BigInteger(toByteArray.reverseView)
  }
  
  def static Int2048 fromBigInteger(BigInteger i) {
    val List<Byte> l = new ArrayList(i.toByteArray.reverseView)
    if (i.signum == -1) {
      while (l.size != 32) {
        l.add(new Byte(0xFF as byte))
      }
    }
    new Int2048(l)
  }
  
  def boolean isNegative() {
    toBigInteger.signum == -1
  }

  def Int2048 negate() {
    toBigInteger.negate.fromBigInteger
  }

  def Int2048 inc() {
    toBigInteger.add(BigInteger.ONE).fromBigInteger
  }

  def Int2048 dec() {
    toBigInteger.subtract(BigInteger.ONE).fromBigInteger
  }

  def Int2048 add(Int2048 other) {
    val _this =  toBigInteger
    val _other = other.toBigInteger
    val result = _this.add(_other)
    if (result.bitLength > 255) {
      throw new OverflowException()
    }
    Int2048.fromBigInteger(result)
  }

  def Int2048 sub(Int2048 other) {
    println(other)
    
    val _this =  toBigInteger
    val _other = other.toBigInteger
    val result = _this.subtract(_other)
    if (result.bitLength > 255) {
      throw new OverflowException()
    }
    Int2048.fromBigInteger(result)
  }
  
  def Int2048 mul(Int2048 other) {
    val _this =  toBigInteger
    val _other = other.toBigInteger
    val result = _this.multiply(_other)
    if (result.bitLength > 255) {
      throw new OverflowException()
    }
    Int2048.fromBigInteger(result)
  }
  
  def Int2048 div(Int2048 other) {
    val _this =  toBigInteger
    val _other = other.toBigInteger
    val result = _this.divide(_other)
    if (result.bitLength > 255) {
      throw new OverflowException()
    }
    Int2048.fromBigInteger(result)
  }
}
