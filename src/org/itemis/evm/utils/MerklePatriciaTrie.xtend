package org.itemis.evm.utils

import org.itemis.types.EVMWord
import org.itemis.utils.Utils

abstract class MerklePatriciaTrie<K, V> {
  extension Utils u = new Utils
  
  def abstract EVMWord hash()
  def abstract void addElement(K key, V value)
  
  static class Null<K, V> extends MerklePatriciaTrie<K, V> {
    override hash() {
      keccak256(newArrayOfSize(0) as byte[])
      throw new UnsupportedOperationException("TODO: auto-generated method stub")
    }
    
    override addElement(K key, V value) {
      throw new UnsupportedOperationException("TODO: auto-generated method stub")
    }
  }
  
  static class Branch<K, V> extends MerklePatriciaTrie<K, V> {
    
  }
  
  static class Leaf<K, V> extends MerklePatriciaTrie<K, V> {
    
  }
  
  static class Extension<K, V> extends MerklePatriciaTrie<K, V> {
    
  }
}