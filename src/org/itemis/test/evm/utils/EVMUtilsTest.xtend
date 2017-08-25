package org.itemis.test.evm.utils

import org.junit.Test
import org.itemis.types.UnsignedByte
import org.junit.Assert
import java.util.List
import org.itemis.evm.utils.EVMUtils
import org.itemis.utils.Utils

class EVMUtilsTest {
  extension Utils u = new Utils
  extension EVMUtils e = new EVMUtils
  
  @Test
  def void testRLP() {
    var UnsignedByte[] result
    
    result = rlp(null as UnsignedByte[])
    Assert.assertEquals(result.length, 1)
    Assert.assertEquals(result.get(0).toHexString, "0x80")
    
    result = rlp("dog".bytes.map[new UnsignedByte(it)] as UnsignedByte[])
    Assert.assertEquals(result.length, 4)
    Assert.assertEquals(result.get(0).toHexString, "0x83")
    Assert.assertEquals(result.get(1).toASCII, "d")
    Assert.assertEquals(result.get(2).toASCII, "o")
    Assert.assertEquals(result.get(3).toASCII, "g")
    
    result = rlp(#["dog", "cat"].map[it.bytes.map[new UnsignedByte(it)]  as UnsignedByte[]])
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
  def void testReverseRLP() {
    var emptyData = #[0x80].map[new UnsignedByte(it)]
    Assert.assertNull(emptyData.reverseRLP.data)
    
    var dog = #[0x83, 0x64, 0x6F, 0x67].map[x | new UnsignedByte(x)]
    Assert.assertEquals(new String(dog.reverseRLP.data.map[byteValue]), "dog")
    
    var dogCat = #[0xC8, 0x83, 0x64, 0x6F, 0x67, 0x83, 0x63, 0x61, 0x74].map[x | new UnsignedByte(x)]
    val dogCatResult = dogCat.reverseRLP.children.map[new String(it.data.map[byteValue])]
    Assert.assertEquals(dogCatResult.length, 2)
    Assert.assertEquals(dogCatResult.get(0), "dog")
    Assert.assertEquals(dogCatResult.get(1), "cat")
    
    var emptyList = #[0xC0].map[x | new UnsignedByte(x)]
    val emptyListResult = emptyList.reverseRLP.children
    Assert.assertEquals(emptyListResult.length, 0)
  }
  
  @Test
  def void testKeccak() {
    Assert.assertEquals(keccak256("".bytes).toString, "0xC5D2460186F7233C927E7DB2DCC703C0E500B653CA82273B7BFAD8045D85A470")
    Assert.assertEquals(keccak256("abc".bytes).toString, "0x4E03657AEA45A94FC7D47BA826C8D667C0D1E6E33A64A036EC44F58FA12D6C45")
    Assert.assertEquals(keccak256("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq".bytes).toString,
                               "0x45D3B367A6904E6E8D502EE04999A7C27647F91FA845D456525FD352AE3D7371")
    Assert.assertEquals(keccak256("abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu".bytes).toString,
                               "0xF519747ED599024F3882238E5AB43960132572B7345FBEB9A90769DAFD21AD67")
  }
}