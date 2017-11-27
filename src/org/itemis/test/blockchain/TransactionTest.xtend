package org.itemis.test.blockchain

import org.junit.Test
import org.itemis.types.impl.Hash256
import org.itemis.utils.StaticUtils
import org.junit.Assert
import org.itemis.types.impl.Address
import org.itemis.blockchain.BlockchainData

class TransactionTest {
  @Test
  def void testHash() {
    Assert.assertEquals(
      BlockchainData.getTransactionByHash(new Hash256(StaticUtils.fromHex("0xe1c28b136505c3fce0bafcdb2d4afad64100ae564495248f0af9abe2be364f72"))).hash,
      new Hash256(StaticUtils.fromHex("0xE1C28B136505C3FCE0BAFCDB2D4AFAD64100AE564495248F0AF9ABE2BE364F72"))
    )
  }
  
  @Test
  def void testSender() {
    Assert.assertEquals(
      BlockchainData.getTransactionByHash(new Hash256(StaticUtils.fromHex("0xc55e2b90168af6972193c1f86fa4d7d7b31a29c156665d15b9cd48618b5177ef"))).sender,
      new Address(StaticUtils.fromHex("0x32be343b94f860124dc4fee278fdcbd38c102d88"))
    )
  }
}