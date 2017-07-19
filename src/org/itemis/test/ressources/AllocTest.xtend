package org.itemis.test.ressources

import org.junit.Test
import org.itemis.ressources.MainnetAllocData
import java.nio.charset.Charset
import org.junit.Assert
import org.itemis.evm.utils.Utils

class AllocTest {
  extension Utils u = new Utils
  
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
    
    val data = reverseRLP(MainnetAllocData.mainnetAllocData)

    Assert.assertEquals(data.children.length, 8893)
  }
}
