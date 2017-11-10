package org.itemis.types

import org.itemis.utils.StaticUtils
import java.math.BigInteger

final class UnsignedByteArray {
  private final UnsignedByte[] array
  
  new() {
    this(32)
  }
  
  new(int length) {
    this.array = newArrayOfSize(length)
    setToZero
  }
  
  new(byte[] array) {
    this(array.map[new UnsignedByte(it)])
  }
  
  new(UnsignedByte[] array) {
    this.array = array
    setToZero
  }
  
  new(UnsignedByteArray other) {
    array = newArrayOfSize(other.length)
    for (var i = 0; i < length; i++) {
      array.set(i, other.get(i))
    }
  }
  
  new(int length, byte[] array) {
    this(length)
    setByteArray(array)
  }
  
  new(int length, UnsignedByte[] array) {
    this(length)
    setUnsignedByteArray(array)
  }
  
  new(int length, UnsignedByteArray array) {
    this(length)
    setUnsignedByteArray(array)
  }
  
  def int length() {
    array.length
  }
  
  def void setToZero() {
    for (var i = 0; i < length; i++) {
      set(i, 0)
    }
  }
  
  def UnsignedByte get(int i) {
    if (i < 0 || i >= length) {
      throw new IllegalArgumentException(String.format("%d is not between 0 and %d", i, length))
    }
    
    array.get(i)
  }
  
  def UnsignedByteArray set(int i, byte value) {
    set(i, new UnsignedByte(value))
  }
  
  def UnsignedByteArray set(int i, int value) {
    set(i, new UnsignedByte(value))
  }
  
  //TODO: refactor *all* exceptions to behave like early returns
  def UnsignedByteArray set(int i, UnsignedByte b) {
    if (i < 0 || i >= length) {
      throw new IllegalArgumentException(String.format("%d is not between 0 and %d", i, length))
    }
    
    val result = new UnsignedByteArray(array)
    result.set(i, b)
    result
  }
  
  def UnsignedByteArray setInt(int value) {
    if (length < 4) {
      throw new IllegalArgumentException("Array is less than 4 bytes long")
    }
    
    setToZero
    set(0, value.bitwiseAnd(0x000000FF))
    set(1, (value >> 8).bitwiseAnd(0x000000FF))
    set(2, (value >> 16).bitwiseAnd(0x000000FF))
    set(3, (value >> 24).bitwiseAnd(0x000000FF))
  }
  
  def UnsignedByteArray setLong(long value) {
    if (length < 8) {
      throw new IllegalArgumentException("Array is less than 8 bytes long")
    }
    
    setToZero
    set(0, value.bitwiseAnd(0x000000FF).byteValue)
    set(1, (value >> 8).bitwiseAnd(0x000000FF).byteValue)
    set(2, (value >> 16).bitwiseAnd(0x000000FF).byteValue)
    set(3, (value >> 24).bitwiseAnd(0x000000FF).byteValue)
    set(4, (value >> 32).bitwiseAnd(0x000000FF).byteValue)
    set(5, (value >> 40).bitwiseAnd(0x000000FF).byteValue)
    set(6, (value >> 48).bitwiseAnd(0x000000FF).byteValue)
    set(7, (value >> 56).bitwiseAnd(0x000000FF).byteValue)
  }
  
  def UnsignedByteArray setByteArray(byte[] array) {
    setUnsignedByteArray(array.map[new UnsignedByte(it)])
  }
  
  def UnsignedByteArray setUnsignedByteArray(UnsignedByte[] array) {
    val result = new UnsignedByteArray(length)
    for (var i = 0; i < Math.min(array.length, length); i++) {
      result.set(i, array.get(i))
    }
    result
  }
  
  def UnsignedByteArray setUnsignedByteArray(UnsignedByteArray array) {
    setUnsignedByteArray(array.array)
  }
  
  def static UnsignedByteArray fromString(String s) {
    new UnsignedByteArray(StaticUtils.fromHex(s))
  }
  
  def byte[] toByteArray() {
    array.map[byteValue]
  }
  
  def UnsignedByte[] toUnsignedByteArray() {
    array
  }
  
  override String toString() {
    toHexString
  }
  
  def String toHexString() {
    var result = "0x"
    for (i : 0 .. length-1) {
      result += this.get(i).toHexString().substring(2)
    }
    result
  }
  
  def String toIntString() {
    toIntString(true)
  }
  
  def String toIntString(boolean bigEndian) {
    if (bigEndian) {
      new BigInteger(toByteArray).toString(10)
    } else {
      new BigInteger(toByteArray.reverseView).toString(10)
    }
  }
  
  def int intValue() {
    intValue(true)
  }
  
  //take lowest significance bytes
  def int intValue(boolean bigEndian) {
    if (length < 4) {
      throw new IllegalArgumentException("Array is less than 4 bytes long")
    }
    
    if (bigEndian) {
      var int result = get(0).intValue
      result = result << 8
      result += get(1).intValue
      result = result << 8
      result += get(2).intValue
      result = result << 8
      result += get(3).intValue
      result
    } else {
      var int result = get(length - 1).intValue
      result = result << 8
      result += get(length - 2).intValue
      result = result << 8
      result += get(length - 3).intValue
      result = result << 8
      result += get(length - 4).intValue
      result
    }
  }
  
  def long unsignedIntValue() {
    unsignedIntValue(true)
  }
  
  def long unsignedIntValue(boolean bigEndian) {
    if (length < 4) {
      throw new IllegalArgumentException("Array is less than 4 bytes long")
    }
    
    if (bigEndian) {
      var long result = get(0).longValue
      result = result << 8
      result += get(1).longValue
      result = result << 8
      result += get(2).longValue
      result = result << 8
      result += get(3).longValue
      result
    } else {
      var long result = get(length - 1).longValue
      result = result << 8
      result += get(length - 2).longValue
      result = result << 8
      result += get(length - 3).longValue
      result = result << 8
      result += get(length - 4).longValue
      result
    }
  }
  
  def long longValue() {
    longValue(true)
  }
  
  def long longValue(boolean bigEndian) {
    if (length < 8) {
      throw new IllegalArgumentException("Array is less than 8 bytes long")
    }
    
    if (bigEndian) {
      var long result = get(0).longValue
      result = result << 8
      result += get(1).longValue
      result = result << 8
      result += get(2).longValue
      result = result << 8
      result += get(3).longValue
      result = result << 8
      result += get(4).longValue
      result = result << 8
      result += get(5).longValue
      result = result << 8
      result += get(6).longValue
      result = result << 8
      result += get(7).longValue
      result
    } else {
      var long result = get(length - 1).longValue
      result = result << 8
      result += get(length - 2).longValue
      result = result << 8
      result += get(length - 3).longValue
      result = result << 8
      result += get(length - 4).longValue
      result = result << 8
      result += get(length - 5).longValue
      result = result << 8
      result += get(length - 6).longValue
      result = result << 8
      result += get(length - 7).longValue
      result = result << 8
      result += get(length - 8).longValue
      result
    }
  }
  
  override boolean equals(Object other) {
    if (other instanceof UnsignedByteArray) {
      var result = true
      for (i : 0 .. length - 1) {
        result = result && this.get(i).equals(other.get(i))
      }
      result
    } else {
      false
    }
  }
  
  override int hashCode() {
    toString.hashCode
  }
  
  def UnsignedByteArray reverse() {
    val result = new UnsignedByteArray(length)
    
    for (var i = 0; i < length; i++) {
      result.set(i, get(i))
    }
    
    result
  }
  
  def UnsignedByteArray invert() {
    val result = new UnsignedByteArray(length)
    
    for (var i = 0; i < length; i++) {
      result.set(i, get(i).invert)
    }
    
    result
  }
  
  def UnsignedByteArray xor(UnsignedByteArray other) {
    if (length != other.length) {
      throw new IllegalArgumentException("Arrays have different lengths")
    }
    
    val result = new UnsignedByteArray(length)
    
    for (var i = 0; i < 32; i++) {
      result.set(i, get(i).byteValue.bitwiseXor(other.get(i).byteValue).byteValue)
    }
    
    result
  }
}