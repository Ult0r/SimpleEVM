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
		//TODO
	}
	
	@Test
	def void testGetBit() {
		//TODO
	}
}