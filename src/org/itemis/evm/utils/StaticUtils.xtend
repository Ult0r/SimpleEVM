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
abstract class StaticUtils {
  // if n = 0, results in bits 0-7
  // if n = 1, bits 8-15
  // etc.
  def static UnsignedByte getNthByteOfInteger(Integer i, int n) {
    new UnsignedByte((i >> (n * 8)).bitwiseAnd(0xFF))
  }

  // must be between 0 and 15
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

  def static UnsignedByte[] unsignedByteArrayFromByteArray(byte[] data) {
    var List<UnsignedByte> result = newArrayList
    for (byte elem : data) {
      result.add(new UnsignedByte(elem))
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


  def static EVMWord keccak256(byte[] input) {
    val byte[] digest = new Keccak.Digest256().digest(input)
    new EVMWord(digest, false)
  }
}
