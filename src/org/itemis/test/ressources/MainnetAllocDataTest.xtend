/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.test.ressources

import org.junit.Test
import org.itemis.ressources.MainnetAllocData
import java.nio.charset.Charset
import org.junit.Assert

class MainnetAllocDataTest {

  @Test
  def void testUTF32Support() {
    try {
      Charset.isSupported("UTF-32")
    } catch(Exception e) {
      Assert.fail("UTF-32 encoding not supported")
    }
  }

  @Test
  def void testAlloc() {
    MainnetAllocData.ensureDataIsWritten

    Assert.assertEquals(MainnetAllocData.getMainnetAllocDataSize, 8893)
    
    val iter = MainnetAllocData.mainnetAllocDataQueryIterator
    while (iter.hasNext) {
      val value = iter.next
      Assert.assertEquals(MainnetAllocData.getBalanceForAddress(value.key), value.value)
    }
  }
}
