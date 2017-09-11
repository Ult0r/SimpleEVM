/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/

package org.itemis.utils

import org.itemis.types.UnsignedByte
import org.itemis.types.EVMWord
import org.bouncycastle.jcajce.provider.digest.Keccak
import java.io.File
import java.nio.file.Files
import org.itemis.types.Nibble

abstract class StaticUtils {
  // if n = 0, results in bits 0-7
  // if n = 1, bits 8-15
  // etc.
  def static UnsignedByte getNthByteOfInteger(Integer i, int n) {
    new UnsignedByte((i >> (n * 8)).bitwiseAnd(0xFF))
  }
  
  def static String toHex(Nibble n) {
    toHex(new UnsignedByte(n.value))
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
      result.append(c.higherNibble.toHex)
      result.append(c.lowerNibble.toHex)
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
    var i = 0
    
    if (data.length % 2 == 1) {
      result.add(new UnsignedByte(new Nibble(0), new Nibble(data.charAt(0).fromHex)))
      i++
    }
    for (; i < data.length; i += 2) {
      result.add(new UnsignedByte(new Nibble(data.charAt(i).fromHex), new Nibble(data.charAt(i + 1).fromHex)))
    }
    
    result.map[byteValue]
  }
  
  def static Nibble[] toNibbles(UnsignedByte[] b) {
    val result = newArrayList
    
    for (_b : b) {
      result.add(_b.higherNibble)
      result.add(_b.lowerNibble) 
    }
    
    result
  }
  
  def static UnsignedByte[] toUnsignedBytes(Nibble[] n) {
    val result = newArrayList
    
    for(var i = 0; i < (n.length / 2); i++) {
      result.add(new UnsignedByte(n.get(i * 2), n.get(i * 2 + 1)))
    }
    
    if (n.length % 2 != 0) {
      result.add(new UnsignedByte(n.get(n.length - 1), new Nibble(0x0)))
    }
    
    result
  }
  
  def static EVMWord keccak256(String input) {
    keccak256(input.bytes)
  }

  def static EVMWord keccak256(byte[] input) {
    val byte[] digest = new Keccak.Digest256().digest(input)
    new EVMWord(digest, true)
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
