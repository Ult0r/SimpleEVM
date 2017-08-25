package org.itemis.test.ressources

import org.junit.Test
import org.itemis.ressources.MainnetAllocData
import java.nio.charset.Charset
import org.junit.Assert
import org.itemis.types.EVMWord

class AllocTest {
  @Test
  def void testUTF32Support() {
    try {
      Charset.isSupported("UTF-32")
    } catch (Exception e) {
      Assert.fail("UTF-32 encoding not supported")
    }
  }
  
  @Test
  def void testAlloc() {
    Assert.assertEquals(MainnetAllocData.mainnetAllocData.length, 286044)
    
    val data = MainnetAllocData.mainnetAllocDataTree

    Assert.assertEquals(data.children.length, 8893)
    
    val _data = MainnetAllocData.mainnetAllocDataMap
    
    Assert.assertEquals(_data.entrySet.toList.length, 8893)
        
    val k = EVMWord.fromString("0x39C773367C8825D3596C686F42BF0D14319E3F84")
    val v = EVMWord.fromString("0x73F75D1A085BA0000")
    Assert.assertEquals(_data.get(k), v)
  }
}
