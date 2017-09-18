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
import org.itemis.evm.utils.MerklePatriciaTrie.Null
import org.itemis.ressources.MainnetAllocData
import org.junit.Test
import org.itemis.utils.Utils
import java.util.List
import org.itemis.types.UnsignedByte
import org.itemis.evm.utils.EVMUtils
import org.itemis.types.NibbleList
import org.itemis.ressources.JsonRPCWrapper
import org.itemis.types.EVMWord
import org.junit.Assert
import org.itemis.utils.db.DataBaseWrapper.DataBaseID
import org.itemis.utils.db.DataBaseWrapper

class MerklePatriciaTrieTest {
  extension Utils u = new Utils
  extension EVMUtils e = new EVMUtils
  extension JsonRPCWrapper j = new JsonRPCWrapper
  extension DataBaseWrapper db = new DataBaseWrapper

  @Test
  def void testEmptyTrie() {
    Assert.assertEquals(new MerklePatriciaTrie("testEmptyTrie").root.hash.elements.toHex,
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
  }

  @Test
  def void testWithAllocData() {
    val MerklePatriciaTrie trie = new MerklePatriciaTrie("testWithAllocData")

    val iter = MainnetAllocData.mainnetAllocDataQueryIterator
    var i = 0
    while(iter.hasNext) {
      val e = iter.next
      trie.addAccount(e.key, e.value)
      println(i++)
    }
    trie.flush
    
    var conn = DataBaseID.TRIE.getConnection("testWithAllocData")
    conn.query("SHUTDOWN")
    conn.close
    conn = DataBaseID.TRIE.getConnection("testWithAllocData")
    val res = conn.query("SELECT COUNT(*) FROM nodes")
    res.next
    val size = res.getLong(1)
    conn.query("SHUTDOWN")
    conn.close
    
    Assert.assertEquals(size, 44410)
    Assert.assertEquals(trie.trieRoot, eth_getBlockByNumber(new EVMWord(0), null).stateRoot)
  }

  def private void addAccount(MerklePatriciaTrie trie, EVMWord address, EVMWord balance) {
    addAccount(trie, address, balance, keccak256(""))
  }

  def private void addAccount(MerklePatriciaTrie trie, EVMWord address, EVMWord balance, EVMWord codeHash) {
    addAccount(trie, address, balance, new EVMWord(new Null().hash.elements, true), codeHash)
  }

  def private void addAccount(MerklePatriciaTrie trie, EVMWord address, EVMWord balance, EVMWord storageRoot,
    EVMWord codeHash) {
    val List<UnsignedByte[]> account = newArrayList

    val nonce = newArrayList
    account.add(nonce)
    account.add(balance.toByteArray.reverse.dropWhile[it.byteValue == 0].toList)
    account.add(storageRoot.toByteArray)
    account.add(codeHash.toByteArray)

    val value = rlp(account)
    val path = keccak256(address.toByteArray.map[byteValue].take(20))

    trie.putElement(new NibbleList(path), value)
  }
}
