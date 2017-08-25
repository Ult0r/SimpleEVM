/*******************************************************************************
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
* 
* Contributors:
* Lars Reimers for itemis AG
*******************************************************************************/

package org.itemis.test.evm.utils

import org.junit.Test
import org.itemis.evm.utils.MerklePatriciaTrie
import org.itemis.types.EVMWord
import org.itemis.utils.Utils

class MerklePatriciaTrieTest {
  extension Utils u = new Utils
      
  @Test
  def void foobar() {
    var MerklePatriciaTrie.Node n = new MerklePatriciaTrie.Null
    println(n.hash)
    n = n.addElement(
      new EVMWord(0).toByteArray.toNibbles,
      new EVMWord(0).toByteArray
    )
    println(n.hash)
  }
}