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
import org.itemis.types.impl.EVMWord
import org.itemis.types.impl.Address

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

    val k = Address.fromString("0x39C773367C8825D3596C686F42BF0D14319E3F84")
    val v = EVMWord.fromString("0x0000BA85A0D1753F07")
    Assert.assertEquals(MainnetAllocData.getBalanceForAddress(k), v)
  }
}
