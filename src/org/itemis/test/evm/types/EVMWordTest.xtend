/*******************************************************************************
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
* 
* Contributors:
* Lars Reimers for itemis AG
*******************************************************************************/

package org.itemis.test.evm.types

import org.junit.Test
import org.itemis.evm.types.EVMWord
import org.junit.Assert
import org.itemis.evm.types.exception.OverflowException

class EVMWordTest {
	private var EVMWord zero = new EVMWord()
	private var EVMWord various = new EVMWord()
	private var EVMWord maxEVMWord = new EVMWord()
	
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
	def void testToHexString() {
		initVarious()
		Assert.assertEquals(zero.toHexString,    "0000000000000000000000000000000000000000000000000000000000000000")
		Assert.assertEquals(various.toHexString, "CAFEBABEDEADBEEFFFEEDDCCBBAA99887766554433221100FEDCBA9876543210")
	}
	
	@Test
	def void testToBitString() {
		initVarious()
		Assert.assertEquals(zero.toBitString,    "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
		Assert.assertEquals(various.toBitString, "1100101011111110101110101011111011011110101011011011111011101111111111111110111011011101110011001011101110101010100110011000100001110111011001100101010101000100001100110010001000010001000000001111111011011100101110101001100001110110010101000011001000010000")
	}
	
	@Test
	def void testEquals() {
		initVarious()
		Assert.assertEquals(zero, zero)
		Assert.assertEquals(various, various)
	}
	
	@Test
	def void testSetToZero() {
		initVarious()
		Assert.assertNotEquals(zero, various)
		Assert.assertEquals(zero, various.setToZero)
	}
	
	@Test
	def void testGetNth16BitField() {
		initVarious()
		Assert.assertEquals(various.getNth16BitField(0), 0x3210)
		Assert.assertEquals(various.getNth16BitField(15), 0xCAFE)
	}
	
	@Test
	def void testIntConstructor() {
		var word = new EVMWord(0xABCD)
		Assert.assertEquals(word.getNth16BitField(0), 0xABCD)
	}
	
	@Test
	def void testInvert() {
		initVarious()
		var word = new EVMWord(0)
		Assert.assertEquals(word.invert.toHexString, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF")
		Assert.assertEquals(various.invert.toHexString, "350145412152411000112233445566778899AABBCCDDEEFF0123456789ABCDEF")
	}
	
	@Test
	def void testNegate() {
		var word = new EVMWord(0xABCD)
		Assert.assertEquals(word.negate.toHexString, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5433")
	}
	
	@Test
	def void testInc() {
		initVarious()
		Assert.assertEquals(zero.inc.toHexString, "0000000000000000000000000000000000000000000000000000000000000001")
		Assert.assertEquals(various.inc.toHexString, "CAFEBABEDEADBEEFFFEEDDCCBBAA99887766554433221100FEDCBA9876543211")
	}
	
	@Test
	def void testDec() {
		initVarious()
		Assert.assertEquals(zero.dec.toHexString, "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF")
		Assert.assertEquals(various.dec.toHexString, "CAFEBABEDEADBEEFFFEEDDCCBBAA99887766554433221100FEDCBA987654320F")
	}
	
	@Test
	def void testAdd() {
		initVarious()
		Assert.assertEquals(zero.add(various), various)
		var word = new EVMWord(0x1234)
		Assert.assertEquals(word.add(new EVMWord(0x4321)), new EVMWord(0x5555))
	}
	
	@Test
	def void testSub() {
		initVarious()
		var various_negate = various.negate
		Assert.assertEquals(zero.sub(various), various_negate)
		var word = new EVMWord(0x5555)
		Assert.assertEquals(word.sub(new EVMWord(0x1234)), new EVMWord(0x4321))
	}
	
	@Test(expected = OverflowException)
	def void testAddOverflow() {
		initMaxEVMWord()
		maxEVMWord.inc
	}
	
	@Test(expected = OverflowException)
	def void testSubOverflow() {
		initMaxEVMWord()
		maxEVMWord.negate.dec
	}
}