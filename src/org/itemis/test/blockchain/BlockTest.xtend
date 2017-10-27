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
import org.itemis.types.EVMWord
import org.junit.Assert

class BlockTest {
  @Test
  def void testGenesis() {
    val Block genesis = Block.genesisBlock
    Assert.assertEquals(genesis.hash, EVMWord.fromString("0xd4e56740f876aef8c010b86a40d5f56745a118d0906a34e69aec8c0db1cb8fa3"))
  }
}
