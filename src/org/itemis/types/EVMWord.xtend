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
import java.math.BigInteger
import java.util.ArrayList

  //TODO replace EVMWord with subclasses (address, hash, etc)
//256-bit / 32-byte int
//[0] contains bits 0-7
//[31] contains bits 248-255
class EVMWord {
  public static final EVMWord ZERO = new EVMWord(0)
  public static final EVMWord ONE  = new EVMWord(1)
  
  private UnsignedByteArray array = new UnsignedByteArray(32)

  new() {
    array.setToZero
  }

  new(int i) {
    array.setInt(i)
  }

  new(long l) {
    array.setLong(l)
  }

  new(EVMWord word) {
    array.setUnsignedByteArray(word.toUnsignedByteArray)
  }

  new(byte[] array) {
    this.array.setByteArray(array)
  }

  new(UnsignedByte[] array) {
    this.array.setUnsignedByteArray(array)
  }

  new(UnsignedByteArray array) {
    this.array.setUnsignedByteArray(array)
  }

  def EVMWord setToZero() {
    array.setToZero
    this
  }

  def static EVMWord fromString(String s) {
    new EVMWord(UnsignedByteArray.fromString(s))
  }

  def UnsignedByte getNthField(Integer n) {
    array.get(n)
  }

  def UnsignedByte[] toUnsignedByteArray() {
    array.toUnsignedByteArray
  }

  def byte[] toByteArray() {
    array.toByteArray
  }

  def EVMWord setNthField(Integer n, int newValue) {
    val newArray = new UnsignedByteArray(array)
    newArray.set(n, newValue)
    new EVMWord(newArray)
  }

  def EVMWord setNthField(Integer n, short newValue) {
    val newArray = new UnsignedByteArray(array)
    newArray.set(n, newValue)
    new EVMWord(newArray)
  }

  def EVMWord setNthField(Integer n, UnsignedByte newValue) {
    val newArray = new UnsignedByteArray(array)
    newArray.set(n, newValue)
    new EVMWord(newArray)
  }

  override String toString() {
    toHexString
  }

  def String toHexString() {
    array.toHexString
  }

  def String toIntString() {
    array.toIntString
  }

  //TODO: exchange unsignedIntValue.intValue with intValue
  def int intValue() {
    array.intValue
  }
  
  def long unsignedIntValue() {
    array.unsignedIntValue
  }

  def long longValue() {
    array.longValue
  }

  override boolean equals(Object other) {
    if(other instanceof EVMWord) {
      array.equals(other.array)
    } else {
      false
    }
  }

  override int hashCode() {
    array.hashCode
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
    new EVMWord(array.reverse)
  }

  def EVMWord invert() {
    new EVMWord(array.invert)
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

  def EVMWord add(int other) {
    add(new EVMWord(other))
  }
  
  def EVMWord add(BigInteger other) {
    add(EVMWord.fromBigInteger(other))
  }
  
  def EVMWord add(EVMWord other) {
    val _this =  toBigInteger
    val _other = other.toBigInteger
    val result = _this.add(_other)
    if (result.bitLength > 255) {
      throw new OverflowException()
    }
    EVMWord.fromBigInteger(result)
  }

  def EVMWord sub(int other) {
    sub(new EVMWord(other))
  }
  
  def EVMWord sub(BigInteger other) {
    sub(EVMWord.fromBigInteger(other))
  }
  
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

  def EVMWord mul(int other) {
    mul(new EVMWord(other))
  }
  
  def EVMWord mul(BigInteger other) {
    mul(EVMWord.fromBigInteger(other))
  }
  
  def EVMWord mul(EVMWord other) {
    val _this =  toBigInteger
    val _other = other.toBigInteger
    val result = _this.multiply(_other)
    if (result.bitLength > 255) {
      throw new OverflowException()
    }
    EVMWord.fromBigInteger(result)
  }

  def EVMWord div(int other) {
    div(new EVMWord(other))
  }
  
  def EVMWord div(BigInteger other) {
    div(EVMWord.fromBigInteger(other))
  }
  
  def EVMWord div(EVMWord other) {
    val _this =  toBigInteger
    val _other = other.toBigInteger
    val result = _this.divide(_other)
    if (result.bitLength > 255) {
      throw new OverflowException()
    }
    EVMWord.fromBigInteger(result)
  }

  def int log(int other) {
    log(new EVMWord(other))
  }
  
  def int log(BigInteger other) {
    log(EVMWord.fromBigInteger(other))
  }
  
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

  def EVMWord mod(int other) {
    mod(new EVMWord(other))
  }
  
  def EVMWord mod(BigInteger other) {
    mod(EVMWord.fromBigInteger(other))
  }
  
  def EVMWord mod(EVMWord other) {
    val _this =  toBigInteger
    val _other = other.toBigInteger
    val result = _this.mod(_other)
    if (result.bitLength > 255) {
      throw new OverflowException()
    }
    EVMWord.fromBigInteger(result)
  }

  def EVMWord divRoundUp(int other) {
    divRoundUp(new EVMWord(other))
  }
  
  def EVMWord divRoundUp(BigInteger other) {
    divRoundUp(EVMWord.fromBigInteger(other))
  }

  def EVMWord divRoundUp(EVMWord other) {
    val _this = toBigInteger
    val _other = other.toBigInteger
    val divRem = _this.divideAndRemainder(_other)
    
    if (divRem.get(1).fromBigInteger.zero) divRem.get(0).fromBigInteger.inc else divRem.get(0).fromBigInteger
  }
  
  def EVMWord xor(EVMWord other) {
    new EVMWord(array.xor(other.array))
  }
  
}
