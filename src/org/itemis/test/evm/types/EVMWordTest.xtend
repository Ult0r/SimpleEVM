package org.itemis.test.evm.types

import org.junit.Test
import org.itemis.evm.types.EVMWord
import org.junit.Before
import org.junit.Assert

class EVMWordTest {
	private val EVMWord zero = new EVMWord()
	private var EVMWord various = new EVMWord()
	
	@Before
	def void init() {
		various.setNthField(0, 0x01)
		various.setNthField(1, 0x23)
		various.setNthField(2, 0x45)
		various.setNthField(3, 0x67)
		various.setNthField(4, 0x89)
		various.setNthField(5, 0xAB)
		various.setNthField(6, 0xCD)
		various.setNthField(7, 0xEF)
		
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
	
	@Test
	def void testToHexString() {
		Assert.assertEquals(zero.toHexString,    "0000000000000000000000000000000000000000000000000000000000000000")
		Assert.assertEquals(various.toHexString, "CAFEBABEDEADBEEFFFEEDDCCBBAA99887766554433221100FEDCBA9876543210")
	}
	
	@Test
	def void testToBitString() {
		
	}
}