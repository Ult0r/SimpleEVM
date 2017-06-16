package org.itemis.test.evm

import org.itemis.evm.Utils
import org.junit.Test
import org.junit.Assert
import org.itemis.evm.types.UnsignedByte

class UtilsTest {
	extension Utils u = new Utils

	private val Integer zero = 0
	private val Integer _0x03020100 = ((3 << 8) + 2 << 8) + 1 << 8

	@Test
	def void testGetNthByteOfInteger() {
		Assert.assertEquals(zero.getNthByteOfInteger(0), new UnsignedByte(0))
		Assert.assertEquals(zero.getNthByteOfInteger(1), new UnsignedByte(0))
		Assert.assertEquals(zero.getNthByteOfInteger(2), new UnsignedByte(0))
		Assert.assertEquals(zero.getNthByteOfInteger(3), new UnsignedByte(0))
		
		Assert.assertEquals(_0x03020100.getNthByteOfInteger(0), new UnsignedByte(0))
		Assert.assertEquals(_0x03020100.getNthByteOfInteger(1), new UnsignedByte(1))
		Assert.assertEquals(_0x03020100.getNthByteOfInteger(2), new UnsignedByte(2))
		Assert.assertEquals(_0x03020100.getNthByteOfInteger(3), new UnsignedByte(3))
	}

	@Test
	def void testToHexString() {
		Assert.assertEquals(new UnsignedByte(0xE5).toHexString, "E5")
	}
	
	@Test
	def void testToHex() {
		Assert.assertEquals(new UnsignedByte(0).toHex, "0")
		Assert.assertEquals(new UnsignedByte(1).toHex, "1")
		Assert.assertEquals(new UnsignedByte(2).toHex, "2")
		Assert.assertEquals(new UnsignedByte(3).toHex, "3")
		Assert.assertEquals(new UnsignedByte(4).toHex, "4")
		Assert.assertEquals(new UnsignedByte(5).toHex, "5")
		Assert.assertEquals(new UnsignedByte(6).toHex, "6")
		Assert.assertEquals(new UnsignedByte(7).toHex, "7")
		Assert.assertEquals(new UnsignedByte(8).toHex, "8")
		Assert.assertEquals(new UnsignedByte(9).toHex, "9")
		Assert.assertEquals(new UnsignedByte(10).toHex, "A")
		Assert.assertEquals(new UnsignedByte(11).toHex, "B")
		Assert.assertEquals(new UnsignedByte(12).toHex, "C")
		Assert.assertEquals(new UnsignedByte(13).toHex, "D")
		Assert.assertEquals(new UnsignedByte(14).toHex, "E")
		Assert.assertEquals(new UnsignedByte(15).toHex, "F")
		Assert.assertEquals(new UnsignedByte(16).toHex, "10")
	}
	
	@Test
	def void testToBitString() {
		Assert.assertEquals(new UnsignedByte(42).toBitString, "00101010")
	}
}
