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

import java.math.BigInteger
import org.itemis.types.EVMWord
import org.itemis.utils.StaticUtils
import java.util.Arrays
import org.itemis.blockchain.Block
import java.util.List
import org.itemis.types.EthashNonce
import org.itemis.types.Hash256

abstract class Ethash {
  private static final BigInteger TWO = BigInteger.valueOf(2)
  
  static final BigInteger WORD_BYTES = BigInteger.valueOf(4)
  static final BigInteger DATASET_BYTES_INIT = TWO.pow(30)
  static final BigInteger DATASET_BYTES_GROWTH = TWO.pow(23)
  static final BigInteger CACHE_BYTES_INIT = TWO.pow(24)
  static final BigInteger CACHE_BYTES_GROWTH = TWO.pow(17)
  //static final BigInteger CACHE_MULTIPLIER = BigInteger.valueOf(1024) //unused
  static final BigInteger EPOCH_LENGTH = BigInteger.valueOf(30000)
  static final BigInteger MIX_BYTES = BigInteger.valueOf(128)
  static final BigInteger HASH_BYTES = BigInteger.valueOf(64)
  static final BigInteger DATASET_PARENTS = BigInteger.valueOf(256)
  static final BigInteger CACHE_ROUNDS = BigInteger.valueOf(3)
  static final BigInteger ACCESSES = BigInteger.valueOf(64)
  
  static final BigInteger FNV_PRIME = new BigInteger("01000193", 16)
  
  //XXX: endian?
  def private static byte[] longToHashBytes(long l) {
    val result = newByteArrayOfSize(HASH_BYTES.intValue)
    
    for (var i = 0; i < HASH_BYTES.intValue; i++) {
      if (i < 8) { //long has 8 bytes
        result.set(i, (l >> (i * 8)).bitwiseAnd(0xFF#L) as byte)
      } else {
        result.set(i, 0 as byte)
      }
    }
    
    result
  }
  
  def private static byte[] ensureLength(byte[] array, int length) {
    if (array.length >= length) {
      array
    } else {
      val result = newByteArrayOfSize(length)
      
      for (var i = 0; i < length; i++) {
        result.set(i, if (i < array.length) {
          array.get(i)
        } else {
          0 as byte
        })
      }
      
      result
    }
  }
  
  def private static byte[] byteWiseXOR(byte[] a, byte[] b) {
    if (a.length != b.length) {
      throw new IllegalArgumentException("unequal lengths")
    }
    
    val result = newByteArrayOfSize(a.length)
    for (var i = 0; i < a.length; i++) {
      result.set(i, a.get(i).bitwiseXor(b.get(i)) as byte)
    }
    
    result
  }
  
  def private static BigInteger getEpoch(EVMWord blockNumber) {
    blockNumber.toBigInteger.divide(EPOCH_LENGTH)
  }
  
  def private static BigInteger getPrime(BigInteger x, BigInteger y) {
    if (StaticUtils.isPrime(x.divide(y))) {
      x
    } else {
      getPrime(x.subtract(y), y)
    }
  }
  
  def public static BigInteger getDataSize(EVMWord blockNumber) {
    getPrime(DATASET_BYTES_INIT.add(DATASET_BYTES_GROWTH.multiply(getEpoch(blockNumber))).subtract(MIX_BYTES), MIX_BYTES)
  }
  
  def public static BigInteger getCacheSize(EVMWord blockNumber) {
    getPrime(CACHE_BYTES_INIT.add(CACHE_BYTES_GROWTH.multiply(getEpoch(blockNumber))).subtract(HASH_BYTES), HASH_BYTES)
  }
  
  def public static Hash256 getSeedHash(BigInteger epoch) {
    if (epoch.equals(BigInteger.ZERO)) {
      Hash256.ZERO //XXX: NOT KEC(0^^32) like described in the paper
    } else {
      StaticUtils.keccak256(getSeedHash(epoch.subtract(BigInteger.ONE)).toByteArray)
    }
  }
  
  def public static Hash256 getSeedHash(EVMWord blockNumber) {
    getSeedHash(getEpoch(blockNumber))
  }
  
  def private static byte[] getHashBytesSizedElement(byte[] array, int index) {
    val hashBytes = HASH_BYTES.intValue
    try {
      Arrays.copyOfRange(array, index * hashBytes, index * hashBytes + hashBytes)
    } catch (Exception e) {
      throw e
    }
  }
  
  def private static byte[] setHashBytesSizedElement(byte[] array, int index, byte[] value) {
    val hashBytes = HASH_BYTES.intValue
    if (value.length != hashBytes) {
      throw new IllegalArgumentException("value has length " + value.length)
    }
    
    System.arraycopy(value, 0, array, index * hashBytes, hashBytes)
    array
  }
  
  //Little Endian
  def private static long getIntElement(byte[] array, int index) {
    try {
      var concat = newByteArrayOfSize(5)
      System.arraycopy(array, index * 4, concat, 0, 4)
      concat = concat.reverse
      concat.set(0, 0 as byte)
      new BigInteger(concat).longValue
    } catch (Exception e) {
      throw e
    }
  }
  
  def private static byte[] setIntElement(byte[] array, int index, long value) {
    val List<Byte> bytes = newArrayList()
    bytes.addAll(BigInteger.valueOf(value).toByteArray.reverseView.take(4).toList)
    if (bytes.size < 4) {
      bytes.add(0, 0 as byte)
    }
    if (bytes.size != 4) {
      throw new IllegalArgumentException("value has length " + bytes.size)
    }
    for (var i = 0; i < 4; i++) {
      array.set(index * 4 + i, bytes.get(i))
    }
    array
  }
  
  //using an array here won't work anymore once we reach a cache size of > 2^32
  //that will only happen in about 400 years so no worries
  def public static byte[] initCache(EVMWord blockNumber) {
    val csize = getCacheSize(blockNumber)
    val n = csize.divide(HASH_BYTES).intValue
    val result = newByteArrayOfSize(csize.intValue)
    
    result.setHashBytesSizedElement(0, StaticUtils.keccak512(getSeedHash(blockNumber).toByteArray).toByteArray)
    for (var i = 1; i < n; i++) {
      result.setHashBytesSizedElement(i, StaticUtils.keccak512(result.getHashBytesSizedElement(i - 1)).toByteArray)
    }
    
    result
  }
  
  def private static byte[] randMemoHash(byte[] cache, EVMWord blockNumber) {
    val csize = getCacheSize(blockNumber)
    val n = csize.divide(HASH_BYTES).intValue
    
    for (var i = 0; i < n; i++) {
      val srcOff = (i - 1 + n) % n
      val xorOff = (cache.getHashBytesSizedElement(i).getIntElement(0) % n) as int //XXX: accessing as 32 bit uint
      
      val xor = byteWiseXOR(cache.getHashBytesSizedElement(srcOff), cache.getHashBytesSizedElement(xorOff))
      val hash = StaticUtils.keccak512(xor).toByteArray
      
      cache.setHashBytesSizedElement(i, hash)
    }
    
    cache
  }
  
  def public static byte[] getCache(EVMWord blockNumber) {
    var byte[] cache = initCache(blockNumber) 
    for (var y = 0; y < CACHE_ROUNDS.intValue; y++) {
      cache = randMemoHash(cache, blockNumber)
    }
    cache
  }
  
  
  //XXX: for both fnv methods: other order of operation than in the paper
  //XXX: -> ((x * 0x01000193) ^ y) % 2^32 instead of (x * (0x01000193 ^ y)) % 2^32
  def private static long fnv(long x, long y) {
    BigInteger.valueOf(x).multiply(FNV_PRIME).xor(BigInteger.valueOf(y)).mod(TWO.pow(32)).longValue
  }
  
  //XXX: apparently works intwise (see algorithm.go in geth)
  def private static byte[] fnv(byte[] x, byte[] y) {
    if (x.length != y.length || x.length % 4 != 0) {
      throw new IllegalArgumentException("arrays don't have same lengths")
    }
    val byte[] result = newByteArrayOfSize(x.length)
    for (var i = 0; i < x.length / 4; i++) {
      result.setIntElement(i, (x.getIntElement(i) * FNV_PRIME.intValue).bitwiseXor(y.getIntElement(i)))
    }
    
    result
  }
  
  def private static byte[] mix(byte[] m, byte[] c, long i, int p, BigInteger csize) {
    var byte[] hash = m
    
    if (p == 0) {
      val cIndex = (i % csize.divide(HASH_BYTES).longValue) as int
      val cElement = c.getHashBytesSizedElement(cIndex)
      val xor = byteWiseXOR(cElement, i.longToHashBytes)
      hash = StaticUtils.keccak512(xor).toByteArray
    }
    
    //XXX: this part is also done for p == 0 (paper says the opposite)
    val xor = i.bitwiseXor(p)
    val mIndex = p % (HASH_BYTES.divide(WORD_BYTES).intValue)
    val mElement = hash.getIntElement(mIndex)
    val fnv = fnv(xor, mElement)
    val fnv_mod = (fnv % csize.divide(HASH_BYTES).longValue) as int
    val cElement = c.getHashBytesSizedElement(fnv_mod)
    val result = fnv(hash, cElement).ensureLength(HASH_BYTES.intValue)
    result
  }
  
  def private static byte[] parents(byte[] c, long i, int p, byte[] m, BigInteger csize) {
    if (p < DATASET_PARENTS.intValue - 2) {
      parents(c, i, p + 1, mix(m, c, i, p + 1, csize), csize)
    } else {
      mix(m, c, i, p + 1, csize)
    }
  }
  
  //HASH_BYTES sized chunk
  //int-index would be too small soon, long required
  def public static byte[] calcDataSetItem(byte[] cache, long index, EVMWord blockNumber) {
    StaticUtils.keccak512(parents(cache, index, -1, null, getCacheSize(blockNumber))).toByteArray //XXX: KEC512 not mentioned in the paper
  }
  
  //MIX_BYTES long
  def private static byte[] newData(byte[] m, byte[] s, int i, EVMWord blockNumber, byte[] cache) {
    val nmix = MIX_BYTES.divide(HASH_BYTES)
    val dsize = getDataSize(blockNumber)
    val result = newByteArrayOfSize(MIX_BYTES.intValue)
    
    for (var j = 0; j < nmix.intValue; j++) {
      val s0 = s.getIntElement(0)
      val xor = i.bitwiseXor(s0)
      val mIndex = i % (MIX_BYTES.divide(WORD_BYTES).intValue)
      val mElement = m.getIntElement(mIndex)
      val fnv = fnv(xor, mElement)
      val modValue = dsize.divide(HASH_BYTES).divide(nmix).intValue
      val mod = fnv % modValue
      val index = mod * nmix.intValue + j
      val dataSetItem = calcDataSetItem(cache, index, blockNumber)
      
      result.setHashBytesSizedElement(
        j,
        dataSetItem
      )
    }
    
    result
  }
  
  //MIX_BYTES long
  //XXX: missing parenthesis and parameter in paper
  def private static byte[] mixDataSet(byte[] m, byte[] s, int i, EVMWord blockNumber, byte[] cache) {
    fnv(m, newData(m, s, i, blockNumber, cache)).ensureLength(HASH_BYTES.intValue)
  }
  
  //MIX_BYTES long
  //XXX: calling this with i = -1 can't work if there is no 'i + 1' since it'd result in calling m[-1]
  def private static byte[] accesses(byte[] m, byte[] s, int i, EVMWord blockNumber, byte[] cache) {
    if (i == ACCESSES.intValue - 2) {
      mixDataSet(m, s, i + 1, blockNumber, cache) //XXX: assuming the paper is missing a "+ 1"
    } else {
      accesses(mixDataSet(m, s, i + 1, blockNumber, cache), s, i + 1, blockNumber, cache) //XXX: assuming the paper is missing a "+ 1"
    }
  }
  
  //MIX_BYTES/WORD_BYTES long
  //compresses 4*4 bytes to 4 bytes repeatedly
  def private static byte[] compress(byte[] m, int i) {
    val fnv1 = fnv(m.getIntElement(i + 4), m.getIntElement(i + 5))
    val fnv2 = fnv(fnv1, m.getIntElement(i + 6))
    val fnv3 = fnv(fnv2, m.getIntElement(i + 7))
    
    if (i >= (m.size / WORD_BYTES.intValue) - 8) { //XXX: divide by 4 to account for 32 bit ints being used
      //XXX: theoretically modifying the mix shouldn't happen here anymore according to the paper 
      m.setIntElement((i + 4) / 4, fnv3).take(MIX_BYTES.divide(WORD_BYTES).intValue) //take only the first MIX_BYTES/WORD_BYTES bytes
    } else {
      compress(
        m.setIntElement((i + 4) / 4, fnv3), //XXX: set it in the mix instead of returning it as the only value
        i + 4 //XXX: changed to i + 4 from i + 8
      )
    }
  }
  
  //HASH_BYTES long
  def private static byte[] sh(byte[] h, byte[] n) {
    val byte[] concat = newByteArrayOfSize(h.length + n.length)
    val byte[] nReversed = n.reverseView
    
    System.arraycopy(h, 0, concat, 0, h.length)
    System.arraycopy(nReversed, 0, concat, h.length, n.length)
    
    StaticUtils.keccak512(concat).toByteArray
  }
  
  //MIX_BYTES/WORD_BYTES long
  def private static byte[] mc(byte[] h, byte[] n, EVMWord blockNumber, byte[] cache) {
    val nmix = MIX_BYTES.divide(HASH_BYTES)
    val seedHash = sh(h, n)
    val seedHashConcat = newByteArrayOfSize(nmix.multiply(HASH_BYTES).intValue)
    
    for (var i = 0; i < nmix.intValue; i++) {
      seedHashConcat.setHashBytesSizedElement(i, seedHash)
    }
    
    compress(
      accesses(
        seedHashConcat,
        seedHash, 
        -1,
        blockNumber,
        cache        
      ),
      -4
    )
  }
  
  //nonce is 8 bytes long
  //XXX: the paper states the first parameter to be the hash of the rlp-encoded header without nonce -> needs to be the header itself
  //XXX: does NOT apply for block #0 aka. genesis block!
  def public static Pair<Hash256, Hash256> proofOfWork(Block block) {
    proofOfWork(block.headerRLPHash.toByteArray, block.nonce, block.number)
  }
  
  def public static Pair<Hash256, Hash256> proofOfWork(Block block, EthashNonce nonce, EVMWord blockNumber) {
    proofOfWork(block.headerRLPHash.toByteArray, nonce, blockNumber)
  }
   
  def public static Pair<Hash256, Hash256> proofOfWork(byte[] header, EthashNonce nonce, EVMWord blockNumber) {
    val cache = getCache(blockNumber)
    val mix = mc(header, nonce.toByteArray, blockNumber, cache)
    val seedHash = sh(header, nonce.toByteArray)
    
    val concat = newByteArrayOfSize(HASH_BYTES.add(MIX_BYTES.divide(WORD_BYTES)).intValue)
    System.arraycopy(seedHash, 0, concat, 0, seedHash.length)
    System.arraycopy(mix, 0, concat, seedHash.length, mix.length)
    
    Pair.of(
      new Hash256(mix),
      StaticUtils.keccak256(concat)
    )
  }
}