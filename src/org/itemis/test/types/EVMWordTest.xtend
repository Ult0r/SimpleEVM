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
    various.setNthField(0, 0x10)
    various.setNthField(1, 0x32)
    various.setNthField(2, 0x54)
    various.setNthField(3, 0x76)
    various.setNthField(4, 0x98)
    various.setNthField(5, 0xBA)
    various.setNthField(6, 0xDC)
    various.setNthField(7, 0xFE)

    various.setNthField(8, 0x00)
    various.setNthField(9, 0x11)
    various.setNthField(10, 0x22)
    various.setNthField(11, 0x33)
    various.setNthField(12, 0x44)
    various.setNthField(13, 0x55)
    various.setNthField(14, 0x66)
    various.setNthField(15, 0x77)

    various.setNthField(16, 0x88)
    various.setNthField(17, 0x99)
    various.setNthField(18, 0xAA)
    various.setNthField(19, 0xBB)
    various.setNthField(20, 0xCC)
    various.setNthField(21, 0xDD)
    various.setNthField(22, 0xEE)
    various.setNthField(23, 0xFF)

    various.setNthField(24, 0xEF)
    various.setNthField(25, 0xBE)
    various.setNthField(26, 0xAD)
    various.setNthField(27, 0xDE)
    various.setNthField(28, 0xBE)
    various.setNthField(29, 0xBA)
    various.setNthField(30, 0xFE)
    various.setNthField(31, 0xCA)
  }

  def void initMaxEVMWord() {
    maxEVMWord.setNthField(0, 0xFF)
    maxEVMWord.setNthField(1, 0xFF)
    maxEVMWord.setNthField(2, 0xFF)
    maxEVMWord.setNthField(3, 0xFF)
    maxEVMWord.setNthField(4, 0xFF)
    maxEVMWord.setNthField(5, 0xFF)
    maxEVMWord.setNthField(6, 0xFF)
    maxEVMWord.setNthField(7, 0xFF)

    maxEVMWord.setNthField(8, 0xFF)
    maxEVMWord.setNthField(9, 0xFF)
    maxEVMWord.setNthField(10, 0xFF)
    maxEVMWord.setNthField(11, 0xFF)
    maxEVMWord.setNthField(12, 0xFF)
    maxEVMWord.setNthField(13, 0xFF)
    maxEVMWord.setNthField(14, 0xFF)
    maxEVMWord.setNthField(15, 0xFF)

    maxEVMWord.setNthField(16, 0xFF)
    maxEVMWord.setNthField(17, 0xFF)
    maxEVMWord.setNthField(18, 0xFF)
    maxEVMWord.setNthField(19, 0xFF)
    maxEVMWord.setNthField(20, 0xFF)
    maxEVMWord.setNthField(21, 0xFF)
    maxEVMWord.setNthField(22, 0xFF)
    maxEVMWord.setNthField(23, 0xFF)

    maxEVMWord.setNthField(24, 0xFF)
    maxEVMWord.setNthField(25, 0xFF)
    maxEVMWord.setNthField(26, 0xFF)
    maxEVMWord.setNthField(27, 0xFF)
    maxEVMWord.setNthField(28, 0xFF)
    maxEVMWord.setNthField(29, 0xFF)
    maxEVMWord.setNthField(30, 0xFF)
    maxEVMWord.setNthField(31, 0x7F)
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
  def void testToBitString() {
    init()
    Assert.assertEquals(zero.toBitString,
      "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
    Assert.assertEquals(various.toBitString,
      "0001000000110010010101000111011010011000101110101101110011111110000000000001000100100010001100110100010001010101011001100111011110001000100110011010101010111011110011001101110111101110111111111110111110111110101011011101111010111110101110101111111011001010")
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
  def void testSetToZero() {
    init()
    Assert.assertNotEquals(zero, various)
    Assert.assertEquals(zero, various.setToZero)
  }

  @Test
  def void testFromString() {
    init()
    Assert.assertEquals(EVMWord.fromString("0x400000000").toHexString,
      "0x4000000000000000000000000000000000000000000000000000000000000000")
  }

  @Test
  def void testGetNth16BitField() {
    init()
    Assert.assertEquals(various.getNth16BitField(0), 0x3210)
    Assert.assertEquals(various.getNth16BitField(15), 0xCAFE)
  }

  @Test
  def void testToUnsignedInt() {
    init()
    var word = new EVMWord(0xDEAD)
    Assert.assertEquals(word.toUnsignedInt(), 0xDEAD)
  }

  @Test
  def void testIntConstructor() {
    init()
    var word = new EVMWord(0xABCD)
    Assert.assertEquals(word.getNth16BitField(0), 0xABCD)
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
    Assert.assertEquals(word.add(new EVMWord(0x4321)), new EVMWord(0x5555))
  }

  @Test
  def void testSub() {
    init()
    var various_negate = various.negate
    Assert.assertEquals(zero.sub(various), various_negate)
    var word = new EVMWord(0x5555)
    Assert.assertEquals(word.sub(new EVMWord(0x1234)), new EVMWord(0x4321))
  }

  @Test(expected=OverflowException)
  def void testAddOverflow() {
    init()
    maxEVMWord.add(EVMWord.ONE)
  }

  @Test(expected=OverflowException)
  def void testSubOverflow() {
    init()
    maxEVMWord.negate.sub(new EVMWord(2))
  }
}
