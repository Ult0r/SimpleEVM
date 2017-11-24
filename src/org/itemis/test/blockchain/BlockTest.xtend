/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/

package org.itemis.test.blockchain

import org.junit.Test
import org.itemis.blockchain.Block
import org.junit.Assert
import org.itemis.types.impl.Hash256
import org.itemis.ressources.JsonRPCWrapper
import org.itemis.utils.StaticUtils
import org.bouncycastle.jce.ECNamedCurveTable
import java.math.BigInteger
import org.bouncycastle.asn1.x9.X9IntegerConverter
import org.bouncycastle.math.ec.ECAlgorithms
import org.bouncycastle.math.ec.ECPoint
import org.bouncycastle.math.ec.custom.sec.SecP256K1Curve

class BlockTest {
  extension JsonRPCWrapper j = new JsonRPCWrapper()
  
  @Test
  def void testGenesis() {
    val Block genesis = Block.genesisBlock
    Assert.assertEquals(
      genesis.hash,
      Hash256.fromString("0xD4E56740F876AEF8C010B86A40D5F56745A118D0906A34E69AEC8C0DB1CB8FA3"))
  }
  
  @Test
  //TODO: remove
  def void testCipolla() {
    val tx = eth_getTransactionByHash(new Hash256(StaticUtils.fromHex("0xe1c28b136505c3fce0bafcdb2d4afad64100ae564495248f0af9abe2be364f72")))
    
    val recId = tx.v.byteValue - 27
    val r = tx.r.toBigInteger
    val s = tx.s.toBigInteger
    val msgHash = tx.messageHash.toByteArray
    
    val compressed = false
    println(r.toString(16))
    println(s.toString(16))
    println(StaticUtils.toHex(msgHash))
    
    val _curve = ECNamedCurveTable.getParameterSpec("secp256k1")
    val n = _curve.n
    val i = BigInteger.valueOf(recId.longValue / 2)
    val x = r.add(i.multiply(n))
    
    val SecP256K1Curve curve = _curve.curve as SecP256K1Curve
    val prime = curve.q
    if (x.compareTo(prime) >= 0) {
      Assert.assertTrue(false)
    }
    
    val x9 = new X9IntegerConverter()
    val compEnc = x9.integerToBytes(x, 1 + x9.getByteLength(curve))
    compEnc.set(0, if ((recId.bitwiseAnd(1)) == 1) 0x03 as byte else 0x02 as byte)
    println(StaticUtils.toHex(compEnc))
    val R = curve.decodePoint(compEnc)
    
    if (!R.multiply(n).isInfinity) {
      Assert.assertTrue(false)
    }
    
    val e = new BigInteger(1, msgHash)
    
    val eInv = BigInteger.ZERO.subtract(e).mod(n)
    val rInv = r.modInverse(n)
    val srInv = rInv.multiply(s).mod(n)
    val eInvrInv = rInv.multiply(eInv).mod(n)
    
    val ECPoint.Fp q = ECAlgorithms.sumOfTwoMultiplies(_curve.g, eInvrInv, R, srInv) as ECPoint.Fp
    println(StaticUtils.toHex(q.getEncoded(compressed)))
  }
}






