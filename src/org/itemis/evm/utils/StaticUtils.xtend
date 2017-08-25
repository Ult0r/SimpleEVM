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

import org.itemis.evm.types.UnsignedByte
import java.util.List
import org.itemis.evm.types.EVMWord
import org.bouncycastle.jcajce.provider.digest.Keccak
import java.util.Arrays
import org.itemis.evm.types.Node
import java.io.File
import java.nio.file.Files

abstract class StaticUtils {
  // if n = 0, results in bits 0-7
  // if n = 1, bits 8-15
  // etc.
  def static UnsignedByte getNthByteOfInteger(Integer i, int n) {
    new UnsignedByte((i >> (n * 8)).bitwiseAnd(0xFF))
  }

  def static String toHex(UnsignedByte b) {
    switch b.value as int {
      case 0,
      case 1,
      case 2,
      case 3,
      case 4,
      case 5,
      case 6,
      case 7,
      case 8,
      case 9: b.value.toString
      case 10: "A"
      case 11: "B"
      case 12: "C"
      case 13: "D"
      case 14: "E"
      case 15: "F"
      default: b.toHexString
    }
  }
  
  def static String toHex(UnsignedByte[] array) {
    var result = new StringBuilder("0x")
    
    for (c: array) {
      result.append(c.toHex)
    }
    
    result.toString
  }

  def static byte fromHex(char c) {
    switch c.toString {
      case "0",
      case "1",
      case "2",
      case "3",
      case "4",
      case "5",
      case "6",
      case "7",
      case "8",
      case "9": new Byte(c.toString)
      case "A",
      case "a": 10 as byte
      case "B",
      case "b": 11 as byte
      case "C",
      case "c": 12 as byte
      case "D",
      case "d": 13 as byte
      case "E",
      case "e": 14 as byte
      case "F",
      case "f": 15 as byte
      default: throw new IllegalArgumentException(c + " is not a legal hex character")
    }
  }
  
  def static byte[] fromHex(String s) {
    var data = s
    if (s.startsWith("0x")) {
      data = s.substring(2)
    }
    
    var result = newArrayList
    
    for (c: data.bytes) {
      result.add(fromHex(c as char))
    }
    
    result
  }

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
      result.add(0, getNthByteOfInteger(data.length, 0))

      var size = 1
      while (data.length >= (1 << (8 * size))) {
        result.add(0, getNthByteOfInteger(data.length, size))
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
      result.add(0, getNthByteOfInteger(concatedSerialisations.length, 0))

      var size = 1
      while (concatedSerialisations.length >= (1 << (8 * size))) {
        result.add(0, getNthByteOfInteger(concatedSerialisations.length, size))
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
  
  def static EVMWord keccak256(String input) {
    keccak256(input.bytes)
  }

  def static EVMWord keccak256(byte[] input) {
    val byte[] digest = new Keccak.Digest256().digest(input)
    new EVMWord(digest, false)
  }
  
  def static String rightPad(String input, int length) {
    if (input.length >= length) {
      return input
    }    
    
    val StringBuilder sb = new StringBuilder()
    
    sb.append(input)
    
    for (var i = 0; i < (length - input.length); i++) {
      sb.append(" ")
    }
    
    sb.toString
  }
  
  def static void ensureDirExists(String path) {
    val File dir = new File(path)
    if (!dir.exists) {
      Files.createDirectories(dir.toPath)
    }
  }
}
