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
import org.itemis.blockchain.WorldState
import org.junit.Assert
import org.itemis.types.impl.EVMWord
import org.itemis.blockchain.BlockchainData

class WorldStateTest {
  @Test
  def void testInitWorldState() {
    val ws = new WorldState("testInitWorldState")
    ws.loadGenesisState

    val size = ws.accountCount
    val root = ws.stateRoot

    Assert.assertEquals(size, 8893)
    Assert.assertEquals(root, BlockchainData.getBlockByNumber(EVMWord.ZERO).stateRoot)
  }
}
