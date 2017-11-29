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
import org.itemis.blockchain.BlockchainData
import org.itemis.types.impl.EVMWord
import org.junit.Assert

class ExecutionTest {
  @Test
  def void testExecution() {
    val BACKUP_FREQUENCY = 100
    
    var furthestState = BACKUP_FREQUENCY
    var loadGenesisState = true
    
    new WorldState("testExecution").delete
    
    while (WorldState.exists(furthestState.toString)) {
      furthestState += BACKUP_FREQUENCY
    }
    furthestState -= BACKUP_FREQUENCY
    
    if (furthestState == 0 && WorldState.exists("genesis")) {
      new WorldState("genesis").copyTo("testExecution")
      loadGenesisState = false
    } else if (furthestState > 0) {
      new WorldState(furthestState.toString).copyTo("testExecution")
      loadGenesisState = false
    }
    
    val ws = new WorldState("testExecution")
    ws.makeSavepoint("_")
    if (loadGenesisState) {
      ws.loadGenesisState
    }
    
    if (ws.stateRoot.equals(BlockchainData.getBlockByNumber(EVMWord.ZERO).stateRoot)) {
      ws.copyTo("genesis")
    } else {
      ws.loadSavepoint("_")
      new WorldState("genesis").delete
      Assert.assertTrue(false)
    }
    
    //check for newest backup
    //load it
    //if none found, load genesis
    //iterate over blocks, in a block iterate over transaction, last: apply beneficiary
    //at every threshold backup state
    //log all of the above
  }
}