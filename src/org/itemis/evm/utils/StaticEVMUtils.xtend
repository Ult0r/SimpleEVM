/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.evm.utils

import org.itemis.types.UnsignedByte
import java.util.List
import java.util.Arrays
import org.itemis.utils.StaticUtils
import org.itemis.types.impl.EVMWord
import java.util.function.Predicate
import org.itemis.types.TreeNode

class StaticEVMUtils {
  // recursive length prefix
  def static UnsignedByte[] rlp(UnsignedByte[] data) {
    if(data === null) {
      #[new UnsignedByte(0x80)]
    } else if(data.length == 1 && data.get(0).intValue < 0x80) {
      #[data.get(0)]
    } else if(data.length < 56) {
      var List<UnsignedByte> result = newArrayList
      result.addAll(Arrays.copyOf(data, data.length))
      result.add(0, new UnsignedByte(data.length + 0x80))
      result
    } else {
      var List<UnsignedByte> result = newArrayList
      for (e : data) {
        result.add(e)
      }

      var size = 0
      while(data.length >= (1 << (8 * size))) {
        result.add(0, StaticUtils.getNthByteOfInteger(data.length, size))
        size++
      }
      result.add(0, new UnsignedByte(Math.max(1, size) + 0xB7))
      result
    }
  }

  def static UnsignedByte[] rlp(List<UnsignedByte[]> data) {
    rlp(data, true)
  }

  def static UnsignedByte[] rlp(List<UnsignedByte[]> data, boolean resolveChildren) {
    rlp(data, [resolveChildren])
  }

  def static UnsignedByte[] rlp(List<UnsignedByte[]> data, Predicate<UnsignedByte[]> resolveChildren) {
    var concatedSerialisations = newArrayList
    for (UnsignedByte[] elem : data) {
      if(resolveChildren.test(elem)) {
        concatedSerialisations.addAll(elem.rlp)
      } else {
        concatedSerialisations.addAll(elem)
      }
    }

    var result = newArrayList()
    result.addAll(concatedSerialisations)

    if(concatedSerialisations.length < 56) {
      result.add(0, new UnsignedByte(concatedSerialisations.length + 0xC0))
    } else {
      var size = 0
      var sizeReminder = concatedSerialisations.length
      while(sizeReminder != 0) {
        result.add(0, new UnsignedByte(sizeReminder % 256))
        sizeReminder /= 256
        size++
      }
      result.add(0, new UnsignedByte(size + 0xF7))
    }
    result
  }

  def private static List<TreeNode<UnsignedByte[]>> _reverseRLP(UnsignedByte[] data) {
    var List<TreeNode<UnsignedByte[]>> result = newArrayList
    var usedLength = 0

    if(data === null) { // invalid
      throw new IllegalArgumentException("invalid rlp data")
    } else if(data.length == 0) {
      // do nothing
    } else {
      var _data = data

      while(_data.length != 0) {
        val head = _data.get(0).intValue
        val _head = new UnsignedByte(head)
        switch (head) {
          case 0x80: {
            usedLength = 1
          }
          case head < 0x80: {
            val node = new TreeNode(newArrayList(_head) as UnsignedByte[])
            result.add(node)
            usedLength = 1
          }
          case head <= 0xB7: {
            val dataLength = head - 0x80
            result.add(new TreeNode(Arrays.copyOfRange(_data, 1, 1 + dataLength)))
            usedLength = 1 + dataLength
          }
          case head < 0xC0: {
            val sizeLength = head - 0xB7
            val dataLength = new EVMWord(_data.subList(1, sizeLength + 1).reverseView).intValue
            result.add(new TreeNode(Arrays.copyOfRange(_data, 1 + sizeLength, 1 + sizeLength + dataLength)))
            usedLength = 1 + sizeLength + dataLength
          }
          case head <= 0xF7: {
            val dataLength = head - 0xC0
            var node = new TreeNode()
            node.children.addAll(_reverseRLP(_data.subList(1, dataLength + 1)))
            result.add(node)
            usedLength = 1 + dataLength
          }
          case head > 0xF7: {
            val sizeLength = head - 0xF7
            val dataLength = new EVMWord(_data.subList(1, sizeLength + 1).reverseView).intValue
            var node = new TreeNode()
            node.children.addAll(_reverseRLP(_data.subList(1 + sizeLength, 1 + sizeLength + dataLength)))
            result.add(node)
            usedLength = 1 + sizeLength + dataLength
          }
        }
        _data = _data.subList(usedLength, _data.length)
      }
    }

    result
  }

  def static TreeNode<UnsignedByte[]> reverseRLP(UnsignedByte[] data) {
    if(data.length == 0) {
      throw new IllegalArgumentException("invalid rlp data")
    }

    var result = _reverseRLP(data)
    if(result.length == 1) {
      result.get(0)
    } else {
      var node = new TreeNode()
      node.children.addAll(result)
      node
    }
  }

  def static boolean isValidRLP(UnsignedByte[] data) {
    try {
      if(data.get(0).intValue < 0x80 && data.size > 1) {
        false
      } else {
        reverseRLP(data)
        true
      }
    } catch(Exception e) {
      false
    }
  }
}
