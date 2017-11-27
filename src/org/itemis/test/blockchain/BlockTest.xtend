/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/

package org.itemis.test.blockchain

import org.junit.Test
import org.itemis.blockchain.Block
import org.junit.Assert
import org.itemis.types.impl.Hash256

class BlockTest {
  @Test
  def void testGenesis() {
    val Block genesis = Block.genesisBlock
    Assert.assertEquals(
      genesis.hash,
      Hash256.fromString("0xD4E56740F876AEF8C010B86A40D5F56745A118D0906A34E69AEC8C0DB1CB8FA3"))
  }
}






