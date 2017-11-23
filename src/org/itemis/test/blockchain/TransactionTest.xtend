package org.itemis.test.blockchain

import org.junit.Test
import org.itemis.ressources.JsonRPCWrapper
import org.itemis.types.impl.Hash256
import org.itemis.utils.StaticUtils
import org.itemis.evm.utils.StaticEVMUtils

class TransactionTest {
  extension JsonRPCWrapper j = new JsonRPCWrapper()
  
  @Test
  def void testHash() {
    val tx = eth_getTransactionByHash(new Hash256(StaticUtils.fromHex("0x98afba7bfde015e36a84eb5a9540c79952ddf4176df0a87bea2591a2063cf398")))
    println(tx.hash)
    println(tx.fields.map[StaticUtils.toHex(it)])
    println(StaticUtils.toHex(StaticEVMUtils.rlp(tx.fields)))
  }
}