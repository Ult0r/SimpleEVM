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
import org.itemis.utils.db.DataBaseWrapper.DataBaseID
import org.itemis.utils.db.DataBaseWrapper
import org.junit.Assert

class WorldStateTest {
  extension DataBaseWrapper db = new DataBaseWrapper
    
  @Test
  def void testInitWorldState() {
    val ws = new WorldState("testInitWorldState")
    ws.initTables
    ws.loadGenesisState
    
    val conn = DataBaseID.STATE.getConnection("testInitWorldState")
    val result = conn.query("SELECT COUNT(*) FROM accounts")
    result.next
    Assert.assertEquals(result.getLong(1), 8893)
  }
}
