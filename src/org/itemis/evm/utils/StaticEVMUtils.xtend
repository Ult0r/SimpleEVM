package org.itemis.evm.utils

import org.itemis.types.UnsignedByte
import java.util.List
import java.util.Arrays
import org.itemis.utils.StaticUtils
import org.itemis.types.Node
import org.itemis.types.EVMWord

class StaticEVMUtils {
  def static UnsignedByte[] rlp(Object data) {
    switch (data) {
      UnsignedByte[]: rlp(data)
      List<UnsignedByte[]>: rlp(data)
      List<? extends Object>: rlp(data.map[rlp])
      default: throw new IllegalArgumentException
    }
  }

  // recursive length prefix
  def static UnsignedByte[] rlp(UnsignedByte[] data) {
    if (data === null) {
      #[new UnsignedByte(0x80)]
    } else if (data.length == 1 && data.get(0).intValue < 0x80) {
      #[data.get(0).copy]
    } else if (data.length < 56) {
      var List<UnsignedByte> result = newArrayList
      result.addAll(Arrays.copyOf(data, data.length))
      result.add(0, new UnsignedByte(data.length + 0x80))
      result
    } else {
      var result = Arrays.copyOf(data, data.length)
      result.add(0, StaticUtils.getNthByteOfInteger(data.length, 0))

      var size = 1
      while (data.length >= (1 << (8 * size))) {
        result.add(0, StaticUtils.getNthByteOfInteger(data.length, size))
        size++
      }
      result.add(0, new UnsignedByte(size - 1 + 0xB7))
      result
    }
  }

  def static UnsignedByte[] rlp(List<UnsignedByte[]> data) {
    var concatedSerialisations = newArrayList
    for (UnsignedByte[] elem : data) {
      val UnsignedByte[] _rlp = elem.rlp
      concatedSerialisations.addAll(_rlp)
    }
    var result = newArrayList()
    result.addAll(concatedSerialisations)

    if (concatedSerialisations.length < 56) {
      result.add(0, new UnsignedByte(concatedSerialisations.length + 0xC0))
      result
    } else {
      result.add(0, StaticUtils.getNthByteOfInteger(concatedSerialisations.length, 0))

      var size = 1
      while (concatedSerialisations.length >= (1 << (8 * size))) {
        result.add(0, StaticUtils.getNthByteOfInteger(concatedSerialisations.length, size))
        size++
      }
      result.add(0, new UnsignedByte(size - 1 + 0xF7))
      result
    }
  }

  def private static List<Node<UnsignedByte[]>> _reverseRLP(UnsignedByte[] data) {
    var List<Node<UnsignedByte[]>> result = newArrayList
    var usedLength = 0

    if (data === null) { // invalid
      throw new IllegalArgumentException("invalid rlp data")
    } else if (data.length == 0) {
      // do nothing
    } else {
      var _data = Arrays.copyOf(data, data.length)
    
      while (_data.length != 0) {
        val head = _data.get(0).intValue
        val _head = new UnsignedByte(head)
        switch (head) {
          case 0x80: {
            usedLength = 1
          }
          case head < 0x80: {
            result.add(new Node(#[_head]))
            usedLength = 1
          }
          case head <= 0xB7: {
            val dataLength = head - 0x80
            result.add(new Node(Arrays.copyOfRange(_data, 1, 1 + dataLength)))
            usedLength = 1 + dataLength
          }
          case head < 0xC0: {
            val sizeLength = head - 0xB7
            val dataLength = new EVMWord(Arrays.copyOfRange(_data, 1, sizeLength + 1), false).toUnsignedInt().intValue
            result.add(new Node(Arrays.copyOfRange(_data, 1 + sizeLength, 1 + sizeLength + dataLength)))
            usedLength = 1 + sizeLength + dataLength
          }
          case head <= 0xF7: {
            val dataLength = head - 0xC0
            var node = new Node()
            node.children.addAll(_reverseRLP(Arrays.copyOfRange(_data, 1, dataLength + 1)))
            result.add(node)
            usedLength = 1 + dataLength
          }
          case head > 0xF7: {
            val sizeLength = head - 0xF7
            val dataLength = new EVMWord(Arrays.copyOfRange(_data, 1, sizeLength + 1), false).toUnsignedInt().intValue
            var node = new Node()
            node.children.addAll(_reverseRLP(Arrays.copyOfRange(_data, 1 + sizeLength, 1 + sizeLength + dataLength)))
            result.add(node)
            usedLength = 1 + sizeLength + dataLength
          }
        }
        _data = Arrays.copyOfRange(_data, usedLength, _data.length)
      }
    }

    result
  }

  def static Node<UnsignedByte[]> reverseRLP(UnsignedByte[] data) {
    if (data.length == 0) {
      throw new IllegalArgumentException("invalid rlp data")
    }

    var result = _reverseRLP(data)
    if (result.length == 1) {
      result.get(0)
    } else {
      var node = new Node()
      node.children.addAll(result)
      node
    }
  }
}