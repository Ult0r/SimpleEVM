package org.itemis.test.evm.types

import org.junit.Test
import org.itemis.evm.types.UnsignedByte
import org.junit.Assert

class UnsignedByteTest {
	private UnsignedByte zero  = new UnsignedByte(0)
	private UnsignedByte _0xE5 = new UnsignedByte(0xE5) 
		
	@Test
	def void testEquals() {
		Assert.assertTrue(zero.equals(zero))
		Assert.assertFalse(zero.equals(_0xE5))
	}
	
	@Test
	def void testGetHigherNibble() {
		Assert.assertEquals(zero.higherNibble, zero)
		Assert.assertEquals(_0xE5.higherNibble, new UnsignedByte(0xE))
	}
	
	@Test
	def void testGetLowerNibble() {
		Assert.assertEquals(zero.higherNibble, zero)
		Assert.assertEquals(_0xE5.higherNibble, new UnsignedByte(0x5))
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
}