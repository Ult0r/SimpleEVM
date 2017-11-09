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
import org.itemis.types.EVMWord
import org.junit.Assert
import java.math.BigInteger
import java.util.Random
import org.apache.commons.math3.complex.Complex

class BlockTest {
  @Test
  def void testGenesis() {
    val Block genesis = Block.genesisBlock
    Assert.assertEquals(genesis.hash, EVMWord.fromString("0xd4e56740f876aef8c010b86a40d5f56745a118d0906a34e69aec8c0db1cb8fa3"))
  }
  
  //TODO: remove
  def BigInteger newtonIteration(BigInteger n, BigInteger x0) {
    val x1 = n.divide(x0).add(x0).shiftRight(1)
    if (x0.equals(x1) || x0.equals(x1.subtract(BigInteger.ONE))) x0 else newtonIteration(n, x1)
  }
  
  def BigInteger root(BigInteger n) {
    newtonIteration(n, BigInteger.ONE)
  }
  
  @Test
  def void testCipolla() {
    val a = new Complex(2)
    val n = new Complex(10)
    val p = new Complex(13)
    
    for (var i = 0; i <= 7; i++) {
//      println(a.add(a.pow(2).subtract(n)).pow(new Complex(i)))
    }
    
    println(new Complex(-6))
    println(new Complex(-6).sqrt)
    println(new Complex(-2).add(new Complex(-6).sqrt.multiply(4)))
    println(new Complex(2).add(new Complex(-6).sqrt))
    println(new Complex(2).add(new Complex(-6).sqrt).pow(2))
  }
  
  @Test
  def void testECDSA() {
    val p = new BigInteger("115792089237316195423570985008687907852837564279074904382605163141518161494337")
    val r = new BigInteger("a34584a8f96769d4acf7b662fe3028186d37e7a7fc75da104b88e96dd0680e6", 16)
    val s = new BigInteger("6b1d4647e07384f138c7cd5ccd07793055d4ff70fdf5fabbd415f5e323da00fb", 16)
    
    Assert.assertEquals(s.pow(3).add(BigInteger.valueOf(7)).modPow(p.subtract(BigInteger.ONE).divide(BigInteger.valueOf(2)), p), BigInteger.ONE)
    
    var rnd = new Random()
    var a = new BigInteger(256, rnd)
    while (a.pow(2).subtract(s).modPow(p.subtract(BigInteger.ONE).divide(BigInteger.valueOf(2)), p).equals(BigInteger.ONE)) {
      a = new BigInteger(256, rnd)
    }
    
    var d = BigInteger.ONE
    
    //val x = a.add(a.pow(2).subtract(s).root).modPow(p.add(BigInteger.ONE).divide(BigInteger.valueOf(2)), p)
  }
}
