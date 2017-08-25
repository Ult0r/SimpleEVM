package org.itemis.evm.utils

import org.itemis.types.EVMWord
import org.itemis.utils.Utils
import org.itemis.types.UnsignedByte
import org.itemis.types.Nibble
import java.util.List

abstract class MerklePatriciaTrie {
  static abstract class Node {
    protected extension Utils u = new Utils
    protected extension EVMUtils e = new EVMUtils
    
    def abstract EVMWord hash()

    def abstract Node addElement(Nibble[] key, UnsignedByte[] value)
  }

  static class Null extends Node {
    override hash() {
      val arr = newByteArrayOfSize(0).map[new UnsignedByte(it)]
      keccak256(rlp(arr).map[byteValue])
    }
    
    override addElement(Nibble[] key, UnsignedByte[] value) {
      new Leaf(key, value)
    }
    
  }

  static class Branch extends Node {
    
    override hash() {
      throw new UnsupportedOperationException("TODO: auto-generated method stub")
    }
    
    override addElement(Nibble[] key, UnsignedByte[] value) {
      throw new UnsupportedOperationException("TODO: auto-generated method stub")
    }
    
  }

  static class Leaf extends Node {
    private List<Nibble> encodedPath = newArrayList
    private List<UnsignedByte> value = newArrayList
    
    new(Nibble[] key, UnsignedByte[] value) {
      if (key.length % 2 == 0) {
        encodedPath.add(new Nibble(0x2))
        encodedPath.add(new Nibble(0x0))
      } else {
        encodedPath.add(new Nibble(0x3))
      }
      encodedPath.addAll(key)
      this.value = value
    }
    
    override hash() {
      val list = newArrayList
      list.add(encodedPath.toUnsignedBytes)
      list.add(value)
      keccak256(rlp(list).map[byteValue])
    }
    
    override addElement(Nibble[] key, UnsignedByte[] value) {
      throw new UnsupportedOperationException("TODO: auto-generated method stub")
    }
    
  }

  static class Extension extends Node {
    
    override hash() {
      throw new UnsupportedOperationException("TODO: auto-generated method stub")
    }
    
    override addElement(Nibble[] key, UnsignedByte[] value) {
      throw new UnsupportedOperationException("TODO: auto-generated method stub")
    }
    
  }
}
