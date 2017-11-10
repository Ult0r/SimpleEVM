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
import org.itemis.evm.OverflowException

//opposing to the signed java.lang.Byte
class Nibble extends Number implements Comparable<Nibble> {
  extension Utils u = new Utils

  private byte value = 0 as byte

  new(byte b) {
    if(b >= 0) {
      value = b
    } else {
      value = b + 16
    }
  }

  new(int i) {
    setValue(i)
  }

  override byteValue() {
    value.byteValue
  }

  override compareTo(Nibble other) {
    value.compareTo(other.value)
  }

  override doubleValue() {
    value.doubleValue
  }

  override equals(Object obj) {
    if(obj instanceof Nibble) {
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
    "0x" + toHex
  }

  def String toBitString() {
    var result = ""
    for (i : 4 .. 0) {
      result += if(getBit(i)) "1" else "0"
    }
    result
  }

  def String toASCII() {
    val c = (value.bitwiseAnd(0x0F) as byte) as char
    c.toString
  }

  override String toString() {
    toHexString
  }

  def short getValue() {
    value
  }

  def void setValue(int v) {
    if(v >= 0 && v <= 15) {
      value = v as byte
    } else {
      throw new InvalidParameterException(v + " is not a value between 0 and 15")
    }
  }

  // true = 1
  // false = 0
  def boolean getBit(int n) {
    if(n >= 0 && n <= 4) {
      (value >> n).bitwiseAnd(0x01) == 1
    } else {
      throw new InvalidParameterException(n + " is not a value between 0 and 4")
    }
  }

  def Nibble invert() {
    new Nibble(value.bitwiseNot.bitwiseAnd(0x00FF))
  }

  def Nibble inc() {
    val newValue = value + 1
    if(newValue > 15) {
      throw new OverflowException()
    }
    new Nibble(newValue.bitwiseAnd(0x00FF))
  }

  def Nibble add(Nibble other) {
    val newValue = value + other.getValue
    if(newValue > 15) {
      throw new OverflowException()
    }
    new Nibble(newValue.bitwiseAnd(0x00FF))
  }

}
