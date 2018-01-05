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
    Assert.assertEquals(
      BlockchainData.getTransactionByHash(new Hash256(StaticUtils.fromHex("0x232265581e5a669d06f147a9770f66d181bec1b993353d7819e8dc704f217f70"))).sender,
      new Address(StaticUtils.fromHex("0xf0c896db24137eda6ec88cf1a95217f8604ae55e"))
    )
    Assert.assertEquals(
      BlockchainData.getTransactionByHash(new Hash256(StaticUtils.fromHex("0xda8981676c9b20e1fd45cb4f8e3ad1aacdd4f4988380eabc3059cfd2048800ff"))).sender,
      new Address(StaticUtils.fromHex("0x4bb96091ee9d802ed039c4d1a5f6216f90f81b01"))
    )
    Assert.assertEquals(
      BlockchainData.getTransactionByHash(new Hash256(StaticUtils.fromHex("0x5c504ed432cb51138bcf09aa5e8a410dd4a1e204ef84bfed1be16dfba1b22060"))).sender,
      new Address(StaticUtils.fromHex("0xa1e4380a3b1f749673e270229993ee55f35663b4"))
    )
  }
}