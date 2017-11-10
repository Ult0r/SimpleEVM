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
import org.itemis.utils.db.DataBaseWrapper
import org.junit.Assert
import org.itemis.types.EVMWord
import org.itemis.ressources.JsonRPCWrapper

class WorldStateTest {
  extension JsonRPCWrapper j = new JsonRPCWrapper

  @Test
  def void testInitWorldState() {
    val ws = new WorldState("testInitWorldState")
    ws.loadGenesisState

    val size = ws.accountCount
    val root = ws.stateRoot

    DataBaseWrapper.closeAllConnections

    Assert.assertEquals(size, 8893)
    Assert.assertEquals(root, eth_getBlockByNumber(EVMWord.ZERO, null).stateRoot)
  }
}
