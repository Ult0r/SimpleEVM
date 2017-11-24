package org.itemis.test.blockchain

import org.junit.Test
import org.itemis.ressources.JsonRPCWrapper
import org.itemis.types.impl.Hash256
import org.itemis.utils.StaticUtils
import org.junit.Assert

class TransactionTest {
  extension JsonRPCWrapper j = new JsonRPCWrapper()
  
  @Test
  def void testHash() {
    Assert.assertEquals(
      eth_getTransactionByHash(new Hash256(StaticUtils.fromHex("0xe1c28b136505c3fce0bafcdb2d4afad64100ae564495248f0af9abe2be364f72"))).hash,
      new Hash256(StaticUtils.fromHex("0xE1C28B136505C3FCE0BAFCDB2D4AFAD64100AE564495248F0AF9ABE2BE364F72"))
    )
  }
}