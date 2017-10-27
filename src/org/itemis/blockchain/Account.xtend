/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.blockchain

import org.itemis.types.EVMWord
import org.eclipse.xtend.lib.annotations.Accessors
import org.itemis.evm.utils.MerklePatriciaTrie
import org.itemis.utils.StaticUtils
import org.itemis.types.NibbleList
import org.itemis.types.UnsignedByte
import java.util.List
import org.itemis.utils.Utils
import org.itemis.evm.utils.EVMUtils
import org.itemis.types.UnsignedByteList
import org.itemis.evm.utils.MerklePatriciaTrie.Leaf

class Account {
  extension Utils u = new Utils
  extension EVMUtils e = new EVMUtils
  
  @Accessors private EVMWord nonce
  @Accessors private EVMWord balance
  @Accessors private EVMWord storageRoot
  @Accessors private EVMWord codeHash
  
  new() {
    this(new EVMWord(0))
  }
  
  new(EVMWord balance) {
    this(
      new EVMWord(0),
      balance,
      MerklePatriciaTrie.EMPTY_TRIE_HASH,
      StaticUtils.keccak256("")
    )
  }
  
  new(EVMWord nonce, EVMWord balance, EVMWord storageRoot, EVMWord codeHash) {
    this.nonce = nonce
    this.balance = balance
    this.storageRoot = storageRoot
    this.codeHash = codeHash
  }
  
  new(MerklePatriciaTrie trie, EVMWord address) {
    this(trie, trie.trieRoot, address)    
  }
  
  new(MerklePatriciaTrie trie, EVMWord rootHash, EVMWord address) {
    val root = trie.getNode(new UnsignedByteList(rootHash.toUnsignedByteArray))
    val path = keccak256(address.toUnsignedByteArray.map[byteValue].take(20))
    
    try {
      val node = root.getNode(trie, new NibbleList(path)) as Leaf
      val tree = reverseRLP(node.value)
            
      this.nonce = new EVMWord(tree.children.get(0).data.map[byteValue])
      this.balance = new EVMWord(tree.children.get(1).data.map[byteValue])
      this.storageRoot = new EVMWord(tree.children.get(2).data.map[byteValue])
      this.codeHash = new EVMWord(tree.children.get(3).data.map[byteValue])
    } catch (Exception e) {
      this.nonce = new EVMWord(0)
      this.balance = new EVMWord(0)
      this.storageRoot = new EVMWord(0)
      this.codeHash = new EVMWord(0)
    }
  }
  
  def void insertIntoTrie(MerklePatriciaTrie trie, EVMWord address) {
    val List<UnsignedByte[]> account = newArrayList

    account.add(nonce.toUnsignedByteArray.reverseView.dropWhile[it.byteValue == 0].toList)
    account.add(balance.toUnsignedByteArray.reverseView.dropWhile[it.byteValue == 0].toList)
    account.add(storageRoot.toUnsignedByteArray)
    account.add(codeHash.toUnsignedByteArray)

    val value = rlp(account)
    val path = keccak256(address.toUnsignedByteArray.map[byteValue].take(20))

    trie.putElement(new NibbleList(path), value)
  }
}
