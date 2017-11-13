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

import org.itemis.evm.utils.MerklePatriciaTrie
import org.itemis.ressources.MainnetAllocData
import org.junit.Test
import org.itemis.utils.Utils
import org.itemis.types.UnsignedByte
import org.itemis.types.NibbleList
import org.itemis.ressources.JsonRPCWrapper
import org.itemis.types.impl.EVMWord
import org.junit.Assert
import org.itemis.utils.db.DataBaseWrapper.DataBaseID
import org.itemis.utils.db.DataBaseWrapper
import org.itemis.blockchain.Account

class MerklePatriciaTrieTest {
  extension Utils u = new Utils
  extension JsonRPCWrapper j = new JsonRPCWrapper
  extension DataBaseWrapper db = new DataBaseWrapper

  @Test
  def void testEmptyTrie() {
    Assert.assertEquals(new MerklePatriciaTrie("testEmptyTrie").root.hash.elements.toHex,
      "0x56E81F171BCC55A6FF8345E692C0F86E5B48E01B996CADC001622FB5E363B421")

    Assert.assertEquals(MerklePatriciaTrie.EMPTY_TRIE_HASH.toHexString,
      "0x56E81F171BCC55A6FF8345E692C0F86E5B48E01B996CADC001622FB5E363B421")
  }

  @Test
  def void testThreeEntries() {
    val MerklePatriciaTrie trie = new MerklePatriciaTrie("testThreeEntries")

    trie.putElement(new NibbleList("doe".bytes.map[new UnsignedByte(it)].toNibbles), "reindeer".bytes.map [
      new UnsignedByte(it)
    ])
    trie.putElement(new NibbleList("dog".bytes.map[new UnsignedByte(it)].toNibbles), "puppy".bytes.map [
      new UnsignedByte(it)
    ])
    trie.putElement(new NibbleList("dogglesworth".bytes.map[new UnsignedByte(it)].toNibbles), "cat".bytes.map [
      new UnsignedByte(it)
    ])

    Assert.assertEquals(trie.trieRoot.toHexString, "0x8AAD789DFF2F538BCA5D8EA56E8ABE10F4C7BA3A5DEA95FEA4CD6E7C3A1168D3")

    DataBaseWrapper.closeAllConnections
  }

  @Test
  def void testWithAllocData() {
    val MerklePatriciaTrie trie = new MerklePatriciaTrie("testWithAllocData")

    val iter = MainnetAllocData.mainnetAllocDataQueryIterator
    while(iter.hasNext) {
      val e = iter.next
      val account = new Account(e.value)
      account.insertIntoTrie(trie, e.key)
    }
    trie.flush

    val conn = DataBaseWrapper.getConnection(DataBaseID.TRIE, "testWithAllocData")
    val res = conn.query("SELECT COUNT(*) FROM nodes")
    res.next
    val size = res.getLong(1)

    Assert.assertEquals(size, 44410)
    Assert.assertEquals(trie.trieRoot, eth_getBlockByNumber(EVMWord.ZERO, null).stateRoot)

    DataBaseWrapper.closeAllConnections
  }
}
