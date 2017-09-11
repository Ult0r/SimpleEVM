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
import java.io.Serializable
import org.itemis.types.Nibble

//uses implementations in static utils
class Utils implements Serializable {
  // if n = 0, results in bits 0-7
  // if n = 1, bits 8-15
  // etc.
  def UnsignedByte getNthByteOfInteger(Integer i, int n) {
    StaticUtils.getNthByteOfInteger(i, n)
  }

  def String toHex(Nibble n) {
    StaticUtils.toHex(n)
  }

  def String toHex(UnsignedByte b) {
    StaticUtils.toHex(b)
  }

  def String toHex(UnsignedByte[] array) {
    StaticUtils.toHex(array)
  }

  def byte fromHex(char c) {
    StaticUtils.fromHex(c)
  }

  def byte[] fromHex(String s) {
    StaticUtils.fromHex(s)
  }

  def Nibble[] toNibbles(UnsignedByte[] b) {
    StaticUtils.toNibbles(b)
  }

  def UnsignedByte[] toUnsignedBytes(Nibble[] n) {
    StaticUtils.toUnsignedBytes(n)
  }

  def EVMWord keccak256(String input) {
    StaticUtils.keccak256(input)
  }

  def EVMWord keccak256(byte[] input) {
    StaticUtils.keccak256(input)
  }

  def String rightPad(String input, int length) {
    StaticUtils.rightPad(input, length)
  }

  def void ensureDirExists(String path) {
    StaticUtils.ensureDirExists(path)
  }
}
