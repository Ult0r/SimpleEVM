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

// TODO replace EVMWord with subclasses (address, hash, etc)
//256-bit / 32-byte int
//[0] contains bits 0-7
//[31] contains bits 248-255
class EVMWord {
  public static final EVMWord ZERO = new EVMWord(0)
  public static final EVMWord ONE = new EVMWord(1)

  private final UnsignedByteArray array

  new() {
    array = new UnsignedByteArray(32)
  }

  new(int i) {
    array = new UnsignedByteArray(32).setInt(i)
  }

  new(long l) {
    array = new UnsignedByteArray(32).setLong(l)
  }

  new(EVMWord word) {
    array = new UnsignedByteArray(32, word.toUnsignedByteArray)
  }

  new(byte[] array) {
    array = new UnsignedByteArray(32, array)
  }

  new(UnsignedByte[] array) {
    array = new UnsignedByteArray(32, array)
  }

  new(UnsignedByteArray array) {
    this.array = new UnsignedByteArray(32, array)
  }

  def static EVMWord fromString(String s) {
    new EVMWord(UnsignedByteArray.fromString(s))
  }

  def UnsignedByte get(Integer n) {
    array.get(n)
  }

  def UnsignedByte[] toUnsignedByteArray() {
    array.toUnsignedByteArray
  }

  def byte[] toByteArray() {
    array.toByteArray
  }

  def EVMWord set(Integer n, int newValue) {
    var newArray = new UnsignedByteArray(array)
    newArray = newArray.set(n, newValue)
    new EVMWord(newArray)
  }

  def EVMWord set(Integer n, short newValue) {
    var newArray = new UnsignedByteArray(array)
    newArray = newArray.set(n, newValue)
    new EVMWord(newArray)
  }

  def EVMWord set(Integer n, UnsignedByte newValue) {
    var newArray = new UnsignedByteArray(array)
    newArray = newArray.set(n, newValue)
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

  // TODO: exchange unsignedIntValue.intValue with intValue
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
    if(this.isNegative && !other.isNegative) {
      false
    } else if(!this.isNegative && other.isNegative) {
      true
    } else if(this.isNegative && other.isNegative) {
      other.negate.greaterThan(this.negate)
    } else {
      for (var i = 31; i >= 0; i--) {
        if(this.get(i) > other.get(i)) {
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
    if(one.lessThan(other)) one else other
  }

  def static EVMWord max(EVMWord one, EVMWord other) {
    if(one.greaterThan(other)) one else other
  }

  def boolean isZero() {
    for (i : 0 .. 31) {
      if(!this.get(i).isZero) {
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
    if(i.signum == -1) {
      while(l.size != 32) {
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

  def EVMWord add(EVMWord other) {
    add(other.toBigInteger)
  }

  def EVMWord add(BigInteger other) {
    val _this = toBigInteger
    val _other = other
    val result = _this.add(_other)
    if(result.bitLength > 255) {
      throw new OverflowException()
    }
    EVMWord.fromBigInteger(result)
  }

  def EVMWord sub(int other) {
    sub(new EVMWord(other))
  }

  def EVMWord sub(EVMWord other) {
    sub(other.toBigInteger)
  }

  def EVMWord sub(BigInteger other) {
    val _this = toBigInteger
    val _other = other
    val result = _this.subtract(_other)
    if(result.bitLength > 255) {
      throw new OverflowException()
    }
    EVMWord.fromBigInteger(result)
  }

  def EVMWord mul(int other) {
    mul(new EVMWord(other))
  }

  def EVMWord mul(EVMWord other) {
    mul(other.toBigInteger)
  }

  def EVMWord mul(BigInteger other) {
    val _this = toBigInteger
    val _other = other
    val result = _this.multiply(_other)
    if(result.bitLength > 255) {
      throw new OverflowException()
    }
    EVMWord.fromBigInteger(result)
  }

  def EVMWord div(int other) {
    div(new EVMWord(other))
  }

  def EVMWord div(EVMWord other) {
    div(other.toBigInteger)
  }

  def EVMWord div(BigInteger other) {
    val _this = toBigInteger
    val _other = other
    val result = _this.divide(_other)
    if(result.bitLength > 255) {
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
    if(other.negative || other.zero || other.dec.zero) {
      throw new IllegalArgumentException("log with negative number, 0 or 1")
    }

    var result = 0
    var tmp = this
    while(tmp.greaterThan(other)) {
      tmp = tmp.div(other)
      result++
    }

    result
  }

  def EVMWord mod(int other) {
    mod(new EVMWord(other))
  }

  def EVMWord mod(EVMWord other) {
    mod(other.toBigInteger)
  }

  def EVMWord mod(BigInteger other) {
    val _this = toBigInteger
    val _other = other
    val result = _this.mod(_other)
    if(result.bitLength > 255) {
      throw new OverflowException()
    }
    EVMWord.fromBigInteger(result)
  }

  def EVMWord divRoundUp(int other) {
    divRoundUp(new EVMWord(other))
  }

  def EVMWord divRoundUp(EVMWord other) {
    divRoundUp(other.toBigInteger)
  }

  def EVMWord divRoundUp(BigInteger other) {
    val _this = toBigInteger
    val _other = other
    val divRem = _this.divideAndRemainder(_other)

    if(divRem.get(1).fromBigInteger.zero) divRem.get(0).fromBigInteger.inc else divRem.get(0).fromBigInteger
  }

  def EVMWord xor(EVMWord other) {
    new EVMWord(array.xor(other.array))
  }

}
