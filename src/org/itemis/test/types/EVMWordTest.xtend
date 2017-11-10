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
import org.itemis.types.EVMWord
import org.junit.Assert
import org.itemis.evm.OverflowException

class EVMWordTest {
  private var EVMWord zero = new EVMWord()
  private var EVMWord various = new EVMWord()
  private var EVMWord maxEVMWord = new EVMWord()

  def void init() {
    zero = EVMWord.ZERO
    initVarious
    initMaxEVMWord
  }

  def void initVarious() {
    various = various.set(0, 0x10)
    various = various.set(1, 0x32)
    various = various.set(2, 0x54)
    various = various.set(3, 0x76)
    various = various.set(4, 0x98)
    various = various.set(5, 0xBA)
    various = various.set(6, 0xDC)
    various = various.set(7, 0xFE)

    various = various.set(8, 0x00)
    various = various.set(9, 0x11)
    various = various.set(10, 0x22)
    various = various.set(11, 0x33)
    various = various.set(12, 0x44)
    various = various.set(13, 0x55)
    various = various.set(14, 0x66)
    various = various.set(15, 0x77)

    various = various.set(16, 0x88)
    various = various.set(17, 0x99)
    various = various.set(18, 0xAA)
    various = various.set(19, 0xBB)
    various = various.set(20, 0xCC)
    various = various.set(21, 0xDD)
    various = various.set(22, 0xEE)
    various = various.set(23, 0xFF)

    various = various.set(24, 0xEF)
    various = various.set(25, 0xBE)
    various = various.set(26, 0xAD)
    various = various.set(27, 0xDE)
    various = various.set(28, 0xBE)
    various = various.set(29, 0xBA)
    various = various.set(30, 0xFE)
    various = various.set(31, 0xCA)
  }

  def void initMaxEVMWord() {
    maxEVMWord = maxEVMWord.set(0, 0xFF)
    maxEVMWord = maxEVMWord.set(1, 0xFF)
    maxEVMWord = maxEVMWord.set(2, 0xFF)
    maxEVMWord = maxEVMWord.set(3, 0xFF)
    maxEVMWord = maxEVMWord.set(4, 0xFF)
    maxEVMWord = maxEVMWord.set(5, 0xFF)
    maxEVMWord = maxEVMWord.set(6, 0xFF)
    maxEVMWord = maxEVMWord.set(7, 0xFF)

    maxEVMWord = maxEVMWord.set(8, 0xFF)
    maxEVMWord = maxEVMWord.set(9, 0xFF)
    maxEVMWord = maxEVMWord.set(10, 0xFF)
    maxEVMWord = maxEVMWord.set(11, 0xFF)
    maxEVMWord = maxEVMWord.set(12, 0xFF)
    maxEVMWord = maxEVMWord.set(13, 0xFF)
    maxEVMWord = maxEVMWord.set(14, 0xFF)
    maxEVMWord = maxEVMWord.set(15, 0xFF)

    maxEVMWord = maxEVMWord.set(16, 0xFF)
    maxEVMWord = maxEVMWord.set(17, 0xFF)
    maxEVMWord = maxEVMWord.set(18, 0xFF)
    maxEVMWord = maxEVMWord.set(19, 0xFF)
    maxEVMWord = maxEVMWord.set(20, 0xFF)
    maxEVMWord = maxEVMWord.set(21, 0xFF)
    maxEVMWord = maxEVMWord.set(22, 0xFF)
    maxEVMWord = maxEVMWord.set(23, 0xFF)

    maxEVMWord = maxEVMWord.set(24, 0xFF)
    maxEVMWord = maxEVMWord.set(25, 0xFF)
    maxEVMWord = maxEVMWord.set(26, 0xFF)
    maxEVMWord = maxEVMWord.set(27, 0xFF)
    maxEVMWord = maxEVMWord.set(28, 0xFF)
    maxEVMWord = maxEVMWord.set(29, 0xFF)
    maxEVMWord = maxEVMWord.set(30, 0xFF)
    maxEVMWord = maxEVMWord.set(31, 0x7F)
  }

  @Test
  def void testByteArrayConstructor() {
    init()
    val byte[] array = #[42 as byte]
    Assert.assertEquals(new EVMWord(array).toHexString,
      "0x2A00000000000000000000000000000000000000000000000000000000000000")
    Assert.assertEquals(new EVMWord(array.reverseView).toHexString,
      "0x2A00000000000000000000000000000000000000000000000000000000000000")
    val byte[] array2 = #[42 as byte, 17 as byte]
    Assert.assertEquals(new EVMWord(array2).toHexString,
      "0x2A11000000000000000000000000000000000000000000000000000000000000")
    Assert.assertEquals(new EVMWord(array2.reverseView).toHexString,
      "0x112A000000000000000000000000000000000000000000000000000000000000")
  }

  @Test
  def void testToHexString() {
    init()
    Assert.assertEquals(zero.toHexString, "0x0000000000000000000000000000000000000000000000000000000000000000")
    Assert.assertEquals(various.toHexString, "0x1032547698BADCFE00112233445566778899AABBCCDDEEFFEFBEADDEBEBAFECA")
  }

  @Test
  def void testToString() {
    init()
    Assert.assertEquals(zero.toString, "0x0000000000000000000000000000000000000000000000000000000000000000")
    Assert.assertEquals(various.toString, "0x1032547698BADCFE00112233445566778899AABBCCDDEEFFEFBEADDEBEBAFECA")
  }

  @Test
  def void testEquals() {
    init()
    Assert.assertEquals(zero, zero)
    Assert.assertEquals(various, various)
  }

  @Test
  def void testFromString() {
    init()
    Assert.assertEquals(EVMWord.fromString("0x400000000").toHexString,
      "0x4000000000000000000000000000000000000000000000000000000000000000")
  }

  @Test
  def void testToUnsignedInt() {
    init()
    var word = new EVMWord(0xDEAD)
    Assert.assertEquals(word.unsignedIntValue(), 0xDEAD)
  }

  @Test
  def void testIntConstructor() {
    init()
    var word = new EVMWord(0xABCD)
    Assert.assertEquals(word.intValue, 0xABCD)
  }

  @Test
  def void testInvert() {
    init()
    var word = EVMWord.ZERO
    Assert.assertEquals(word.invert.toHexString, "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF")
    Assert.assertEquals(various.invert.toHexString, "0xEFCDAB8967452301FFEEDDCCBBAA998877665544332211001041522141450135")
  }

  @Test
  def void testNegate() {
    init()
    var word = new EVMWord(0xABCD)
    Assert.assertEquals(word.negate.toHexString, "0x3354FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF")
  }

  @Test
  def void testInc() {
    init()
    Assert.assertEquals(zero.inc.toHexString, "0x0100000000000000000000000000000000000000000000000000000000000000")
    Assert.assertEquals(various.inc.toHexString, "0x1132547698BADCFE00112233445566778899AABBCCDDEEFFEFBEADDEBEBAFECA")
  }

  @Test
  def void testDec() {
    init()
    Assert.assertEquals(zero.dec.toHexString, "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF")
    Assert.assertEquals(various.dec.toHexString, "0x0F32547698BADCFE00112233445566778899AABBCCDDEEFFEFBEADDEBEBAFECA")
  }

  @Test
  def void testAdd() {
    init()
    Assert.assertEquals(zero.add(various), various)
    var word = new EVMWord(0x1234)
    Assert.assertEquals(word.add(0x4321), new EVMWord(0x5555))
  }

  @Test
  def void testSub() {
    init()
    var various_negate = various.negate
    Assert.assertEquals(zero.sub(various), various_negate)
    var word = new EVMWord(0x5555)
    Assert.assertEquals(word.sub(0x1234), new EVMWord(0x4321))
  }

  @Test(expected=OverflowException)
  def void testAddOverflow() {
    init()
    maxEVMWord.add(EVMWord.ONE)
  }

  @Test(expected=OverflowException)
  def void testSubOverflow() {
    init()
    maxEVMWord.negate.sub(2)
  }
}
