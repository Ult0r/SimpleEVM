/*******************************************************************************
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
* 
* Contributors:
* Lars Reimers for itemis AG
*******************************************************************************/

package org.itemis.test.evm.utils

import org.itemis.evm.utils.Utils
import org.junit.Test
import org.junit.Assert
import org.itemis.evm.types.UnsignedByte
import java.util.List

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
		Assert.assertEquals(new UnsignedByte(16).toHex, "0x10")
	}
	
	@Test
	def void testRLP() {
		var UnsignedByte[] result
		
		result = rlp(null as UnsignedByte[])
		Assert.assertEquals(result.length, 1)
		Assert.assertEquals(result.get(0).toHexString, "0x80")
		
		result = rlp("dog".bytes.unsignedByteArrayFromByteArray)
		Assert.assertEquals(result.length, 4)
		Assert.assertEquals(result.get(0).toHexString, "0x83")
		Assert.assertEquals(result.get(1).toASCII, "d")
		Assert.assertEquals(result.get(2).toASCII, "o")
		Assert.assertEquals(result.get(3).toASCII, "g")
		
		result = rlp(#["dog", "cat"].map[bytes.unsignedByteArrayFromByteArray])
		Assert.assertEquals(result.length, 9)
		Assert.assertEquals(result.get(0).toHexString, "0xC8")
		Assert.assertEquals(result.get(1).toHexString, "0x83")
		Assert.assertEquals(result.get(2).toASCII, "d")
		Assert.assertEquals(result.get(3).toASCII, "o")
		Assert.assertEquals(result.get(4).toASCII, "g")
		Assert.assertEquals(result.get(5).toHexString, "0x83")
		Assert.assertEquals(result.get(6).toASCII, "c")
		Assert.assertEquals(result.get(7).toASCII, "a")
		Assert.assertEquals(result.get(8).toASCII, "t")
		
		var List<UnsignedByte> emptyList = newArrayList
		result = rlp(emptyList)
		Assert.assertEquals(result.length, 1)
		Assert.assertEquals(result.get(0).toHexString, "0xC0")
	}
	
	@Test
	def void testKeccak() {
		Assert.assertEquals(sha3_256("".bytes).toString, "0xA7FFC6F8BF1ED76651C14756A061D662F580FF4DE43B49FA82D80A4B80F8434A")
		Assert.assertEquals(sha3_256("abc".bytes).toString, "0x3A985DA74FE225B2045C172D6BD390BD855F086E3E9D525B46BFE24511431532")
		Assert.assertEquals(sha3_256("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq".bytes).toString,
		                           "0x41C0DBA2A9D6240849100376A8235E2C82E1B9998A999E21DB32DD97496D3376")
		Assert.assertEquals(sha3_256("abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu".bytes).toString,
		                           "0x916F6061FE879741CA6469B43971DFDB28B1A32DC36CB3254E812BE27AAD1D18")
	}
}
