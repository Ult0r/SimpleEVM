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
import java.io.Serializable
import org.itemis.types.Nibble
import java.math.BigInteger
import org.itemis.types.impl.Hash256
import org.itemis.types.impl.Hash512

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

  def String toHex(byte[] array) {
    StaticUtils.toHex(array)
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

  def byte[] fromHex(String s, boolean appendFront) {
    StaticUtils.fromHex(s, appendFront)
  }

  def Nibble[] toNibbles(UnsignedByte[] b) {
    StaticUtils.toNibbles(b)
  }

  def UnsignedByte[] toUnsignedBytes(Nibble[] n) {
    StaticUtils.toUnsignedBytes(n)
  }

  def Hash256 keccak256(String input) {
    StaticUtils.keccak256(input)
  }

  def Hash256 keccak256(byte[] input) {
    StaticUtils.keccak256(input)
  }

  def Hash512 keccak512(String input) {
    StaticUtils.keccak512(input)
  }

  def Hash512 keccak512(byte[] input) {
    StaticUtils.keccak512(input)
  }

  def String rightPad(String input, int length) {
    StaticUtils.rightPad(input, length)
  }

  def void ensureDirExists(String path) {
    StaticUtils.ensureDirExists(path)
  }

  def boolean isPrime(BigInteger number) {
    StaticUtils.isPrime(number)
  }
  
  def byte[] ECDSARecover(int recId, BigInteger s, BigInteger r, Hash256 msgHash) {
    StaticUtils.ECDSARecover(recId, s, r, msgHash)     
  }
}
