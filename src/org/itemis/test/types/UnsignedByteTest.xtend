/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/

package org.itemis.test.types

import org.junit.Test
import org.itemis.types.UnsignedByte
import org.junit.Assert
import org.itemis.evm.OverflowException
import org.itemis.types.Nibble

class UnsignedByteTest {
  private val UnsignedByte zero = new UnsignedByte(0)
  private val UnsignedByte _0xE5 = new UnsignedByte(0xE5)

  @Test
  def void testEquals() {
    Assert.assertTrue(zero.equals(zero))
    Assert.assertFalse(zero.equals(_0xE5))
  }

  @Test
  def void testGetHigherNibble() {
    Assert.assertEquals(zero.higherNibble, new Nibble(0x0))
    Assert.assertEquals(_0xE5.higherNibble, new Nibble(0xE))
  }

  @Test
  def void testGetLowerNibble() {
    Assert.assertEquals(zero.lowerNibble, new Nibble(0x0))
    Assert.assertEquals(_0xE5.lowerNibble, new Nibble(0x5))
  }

  @Test
  def void testGetBit() {
    Assert.assertFalse(zero.getBit(0))
    Assert.assertFalse(zero.getBit(1))
    Assert.assertFalse(zero.getBit(2))
    Assert.assertFalse(zero.getBit(3))
    Assert.assertFalse(zero.getBit(4))
    Assert.assertFalse(zero.getBit(5))
    Assert.assertFalse(zero.getBit(6))
    Assert.assertFalse(zero.getBit(7))

    Assert.assertTrue(_0xE5.getBit(0))
    Assert.assertFalse(_0xE5.getBit(1))
    Assert.assertTrue(_0xE5.getBit(2))
    Assert.assertFalse(_0xE5.getBit(3))
    Assert.assertFalse(_0xE5.getBit(4))
    Assert.assertTrue(_0xE5.getBit(5))
    Assert.assertTrue(_0xE5.getBit(6))
    Assert.assertTrue(_0xE5.getBit(7))
  }

  @Test
  def void testInvert() {
    var UnsignedByte invert = new UnsignedByte(0)
    Assert.assertEquals(zero, invert)
    invert = invert.invert
    Assert.assertEquals(new UnsignedByte(0xFF), invert)

    invert.setValue(0x1A)
    Assert.assertNotEquals(zero, invert)
    Assert.assertNotEquals(_0xE5, invert)
    invert = invert.invert
    Assert.assertEquals(_0xE5, invert)
  }

  @Test(expected=OverflowException)
  def void testInc() {
    var UnsignedByte inc = new UnsignedByte(0)
    Assert.assertEquals(zero, inc)
    inc = inc.inc
    Assert.assertEquals(1, inc.getValue)
    inc = inc.inc
    Assert.assertEquals(2, inc.getValue)

    inc.setValue(0xFF)
    Assert.assertNotEquals(zero, inc)
    inc = inc.inc
  }

  @Test(expected=OverflowException)
  def void testAdd() {
    var UnsignedByte add = new UnsignedByte(0)
    Assert.assertEquals(zero, add)
    add = add.add(zero)
    Assert.assertEquals(zero, add)
    add = add.add(_0xE5)
    Assert.assertEquals(_0xE5, add)

    add.setValue(0xFF)
    Assert.assertNotEquals(zero, add)
    add = add.add(_0xE5)
  }

  @Test
  def void testToHexString() {
    Assert.assertEquals(new UnsignedByte(0xE5).toHexString, "0xE5")
  }

  @Test
  def void testToBitString() {
    Assert.assertEquals(new UnsignedByte(42).toBitString, "00101010")
  }

  @Test
  def void testToASCII() {
    Assert.assertEquals(new UnsignedByte(0x5A).toASCII, "Z")
  }
}
