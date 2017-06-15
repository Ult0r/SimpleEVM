package org.itemis.test.evm

import org.itemis.evm.Utils
import org.junit.Test
import org.junit.Assert

class UtilsTest {
	extension Utils u = new Utils

	@Test
	def void testGetNthByteOfInteger() {
		val Integer zero = 0
		Assert.assertEquals(zero.getNthByteOfInteger(0 as byte), 0 as byte)
		Assert.assertEquals(zero.getNthByteOfInteger(1 as byte), 0 as byte)
		Assert.assertEquals(zero.getNthByteOfInteger(2 as byte), 0 as byte)
		Assert.assertEquals(zero.getNthByteOfInteger(3 as byte), 0 as byte)

		var Integer _0x03020100 = ((3 << 8) + 2 << 8) + 1 << 8
		Assert.assertEquals(_0x03020100.getNthByteOfInteger(0 as byte), 0 as byte)
		Assert.assertEquals(_0x03020100.getNthByteOfInteger(1 as byte), 1 as byte)
		Assert.assertEquals(_0x03020100.getNthByteOfInteger(2 as byte), 2 as byte)
		Assert.assertEquals(_0x03020100.getNthByteOfInteger(3 as byte), 3 as byte)
	}

	@Test
	def void testToHexString() {
		Assert.assertEquals((0xE5 as byte).toHexString, "E5")
	}
	
	@Test
	def void testToHex() {
		Assert.assertEquals((0 as byte).toHex, "0")
		Assert.assertEquals((1 as byte).toHex, "1")
		Assert.assertEquals((2 as byte).toHex, "2")
		Assert.assertEquals((3 as byte).toHex, "3")
		Assert.assertEquals((4 as byte).toHex, "4")
		Assert.assertEquals((5 as byte).toHex, "5")
		Assert.assertEquals((6 as byte).toHex, "6")
		Assert.assertEquals((7 as byte).toHex, "7")
		Assert.assertEquals((8 as byte).toHex, "8")
		Assert.assertEquals((9 as byte).toHex, "9")
		Assert.assertEquals((10 as byte).toHex, "A")
		Assert.assertEquals((11 as byte).toHex, "B")
		Assert.assertEquals((12 as byte).toHex, "C")
		Assert.assertEquals((13 as byte).toHex, "D")
		Assert.assertEquals((14 as byte).toHex, "E")
		Assert.assertEquals((15 as byte).toHex, "F")
		Assert.assertEquals((16 as byte).toHex, "10")
	}
	
	@Test
	def void testToBitString() {
		Assert.assertEquals((42 as byte).toBitString, "00101010")
	}
}
