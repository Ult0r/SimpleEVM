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
import org.itemis.types.Hash256

class BlockTest {
  @Test
  def void testGenesis() {
    val Block genesis = Block.genesisBlock
    Assert.assertEquals(genesis.hash,
      Hash256.fromString("0x04CCCE75526CE01DC06B861228625FDE0A57FD7C91105209459F43764D4A8A17")) // XXX: not the hash saved in the blockchain
  }
}
