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

import java.io.File
import java.math.BigInteger
import java.nio.file.Files
import org.bouncycastle.asn1.x9.X9IntegerConverter
import org.bouncycastle.jcajce.provider.digest.Keccak
import org.bouncycastle.jcajce.provider.digest.RIPEMD160
import org.bouncycastle.jcajce.provider.digest.SHA256
import org.bouncycastle.jce.ECNamedCurveTable
import org.bouncycastle.math.ec.ECAlgorithms
import org.bouncycastle.math.ec.custom.sec.SecP256K1Curve
import org.bouncycastle.math.ec.custom.sec.SecP256K1Point
import org.itemis.types.Nibble
import org.itemis.types.UnsignedByte
import org.itemis.types.impl.Hash256
import org.itemis.types.impl.Hash512

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

  //TODO add to Util
  //TODO remove usages of toHex(UnsignedByte(b))
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

  def static String toHex(byte[] array) {
    toHex(array.map[new UnsignedByte(it)])
  }

  def static String toHex(UnsignedByte[] array) {
    var result = new StringBuilder("0x")

    for (c : array) {
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
    fromHex(s, false)
  }

  def static byte[] fromHex(String s, boolean appendFront) {
    var data = s
    if(s.startsWith("0x")) {
      data = s.substring(2)
    }

    var result = newArrayList
    var i = 0

    if(appendFront) {
      if(data.length % 2 == 1) {
        result.add(new UnsignedByte(new Nibble(0), new Nibble(data.charAt(0).fromHex)))
        i++
      }

      for (; i < data.length; i += 2) {
        result.add(new UnsignedByte(new Nibble(data.charAt(i).fromHex), new Nibble(data.charAt(i + 1).fromHex)))
      }
    } else {
      if(data.length % 2 == 1) {
        for (; i < data.length - 1; i += 2) {
          result.add(new UnsignedByte(new Nibble(data.charAt(i).fromHex), new Nibble(data.charAt(i + 1).fromHex)))
        }
        result.add(new UnsignedByte(new Nibble(0), new Nibble(data.charAt(data.length - 1).fromHex)))
      } else {
        for (; i < data.length; i += 2) {
          result.add(new UnsignedByte(new Nibble(data.charAt(i).fromHex), new Nibble(data.charAt(i + 1).fromHex)))
        }
      }
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

    for (var i = 0; i < (n.length / 2); i++) {
      result.add(new UnsignedByte(n.get(i * 2), n.get(i * 2 + 1)))
    }

    if(n.length % 2 != 0) {
      result.add(new UnsignedByte(n.get(n.length - 1), new Nibble(0x0)))
    }

    result
  }

  def static Hash256 ripemd_160(String input) {
    ripemd_160(input.bytes)
  }

  def static Hash256 ripemd_160(byte[] input) {
    new Hash256(new RIPEMD160.Digest().digest(input))
  }

  def static Hash256 sha2_256(String input) {
    sha2_256(input.bytes)
  }

  def static Hash256 sha2_256(byte[] input) {
    new Hash256(new SHA256.Digest().digest(input))
  }

  def static Hash256 keccak256(String input) {
    keccak256(input.bytes)
  }

  def static Hash256 keccak256(byte[] input) {
    new Hash256(new Keccak.Digest256().digest(input))
  }

  def static Hash512 keccak512(String input) {
    keccak512(input.bytes)
  }

  def static Hash512 keccak512(byte[] input) {
    new Hash512(new Keccak.Digest512().digest(input))
  }

  def static String rightPad(String input, int length) {
    if(input.length >= length) {
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
    if(!dir.exists) {
      Files.createDirectories(dir.toPath)
    }
  }

  def static boolean isPrime(BigInteger number) {
    if(!number.isProbablePrime(4)) {
      return false
    }

    val BigInteger two = new BigInteger("2")
    if(!two.equals(number) && BigInteger.ZERO.equals(number.mod(two))) {
      return false
    }

    for (var BigInteger i = new BigInteger("3"); i.multiply(i).compareTo(number) < 1; i = i.add(two)) {
      if(BigInteger.ZERO.equals(number.mod(i))) {
        return false
      }
    }
    return true
  }
  
  def static byte[] ECDSARecover(int recId, BigInteger s, BigInteger r, Hash256 msgHash) {
    val compressed = false
    
    val _curve = ECNamedCurveTable.getParameterSpec("secp256k1")
    val n = _curve.n
    val i = BigInteger.valueOf((recId / 2) as long)
    val x = r.add(i.multiply(n))
    
    val SecP256K1Curve curve = _curve.curve as SecP256K1Curve
    val prime = curve.q
    if (x.compareTo(prime) >= 0) {
      throw new IllegalArgumentException("Illegal coordinates since everything is modulo Q")
    }
    
    val x9 = new X9IntegerConverter()
    val compEnc = x9.integerToBytes(x, 1 + x9.getByteLength(curve))
    compEnc.set(0, if ((recId.bitwiseAnd(1)) == 1) (0x03 as byte) else (0x02 as byte))
    val R = curve.decodePoint(compEnc)
    
    if (!R.multiply(n).isInfinity) {
      throw new IllegalArgumentException("nR is not a valid curve point")
    }
    
    val e = new BigInteger(1, msgHash.toByteArray)
    
    val eInv = BigInteger.ZERO.subtract(e).mod(n)
    val rInv = r.modInverse(n)
    val srInv = rInv.multiply(s).mod(n)
    val eInvrInv = rInv.multiply(eInv).mod(n)
    
    val SecP256K1Point q = ECAlgorithms.sumOfTwoMultiplies(_curve.g, eInvrInv, R, srInv) as SecP256K1Point
    q.getEncoded(compressed)
  }
}
