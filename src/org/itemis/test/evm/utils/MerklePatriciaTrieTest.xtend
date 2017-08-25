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