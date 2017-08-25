package org.itemis.test.blockchain

import org.junit.Test
import org.itemis.blockchain.WorldState

class WorldStateTest {
  @Test
  def void testInitWorldState() {
    val ws = new WorldState("state")
    ws.initTables
    ws.loadGenesisState
    ws.close()
  }
}