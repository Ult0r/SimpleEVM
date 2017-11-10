package org.itemis.test.evm.utils

import org.junit.Test
import org.itemis.blockchain.Block
import org.itemis.types.EVMWord
import org.junit.Assert
import org.itemis.utils.StaticUtils
import org.itemis.blockchain.BlockchainData
import java.math.BigInteger
import org.itemis.utils.db.DataBaseWrapper
import org.itemis.evm.utils.Ethash

class EthashTest {
  private static final BigInteger TWO = BigInteger.valueOf(2)
  
  @Test
  def public void validateGenesis() {
    Assert.assertEquals(
      Block.genesisBlock.hash.toHexString,
      "0xD4E56740F876AEF8C010B86A40D5F56745A118D0906A34E69AEC8C0DB1CB8FA3"
    )
  }
  
  @Test
  def public void testSeedHash() { //works
    Assert.assertEquals(
      StaticUtils.toHex(Ethash.getSeedHash(EVMWord.ZERO).toByteArray),
      "0x0000000000000000000000000000000000000000000000000000000000000000"
    )
    Assert.assertEquals(
      StaticUtils.toHex(Ethash.getSeedHash(new EVMWord(40000)).toByteArray),
      "0x290DECD9548B62A8D60345A988386FC84BA6BC95484008F6362F93160EF3E563"
    )
  }
  
  @Test
  def public void testCache() { //works
    Assert.assertEquals(
      StaticUtils.toHex(Ethash.initCache(EVMWord.ZERO).take(36).toList),
      "0x0F6F7226432C21D4DFA2A1538A1FDC72EE1FAF405A60E5F408B344A2F5AAB2DDFF0F9C17"
    )
    Assert.assertEquals(
      StaticUtils.toHex(Ethash.getCache(EVMWord.ZERO).take(36).toList),
      "0x5E493E76A1318E50815C6CE77950425532964EBBB8DCF94718991FA9A82EAF37658DE68C"
    )
    Assert.assertEquals(
      StaticUtils.toHex(Ethash.initCache(new EVMWord(40000)).take(36).toList),
      "0x0A205E6D535E4259BDE7D0A687C3F5B78FF65C3D69410A39AE623168B0B7E5116D76EF27"
    )
    Assert.assertEquals(
      StaticUtils.toHex(Ethash.getCache(new EVMWord(40000)).take(36).toList),
      "0x9E41457D823FF2C9D8B8D64349B7A7544EF5F5A3D1DD0BF7AFCCE9131AEE12ABAE176E59"
    )
  }
  
  @Test
  def public void testDataset() { //works
    var cache = Ethash.getCache(EVMWord.ZERO)
    Assert.assertEquals(
      StaticUtils.toHex(Ethash.calcDataSetItem(cache, 0L, EVMWord.ZERO).take(32).toList),
      "0x22DB2229CC516C46D2210086F1AB417E0BD1C3827C5ECC6AF7D3A33F8DAE332B"
    )
    Assert.assertEquals(
      StaticUtils.toHex(Ethash.calcDataSetItem(cache, 1337L, EVMWord.ZERO).take(32).toList),
      "0x857FA970BF666A43C5AE0B6B9C4D7D59445B915A34BA69C61A7C00967CBA2931"
    )
    cache = Ethash.getCache(new EVMWord(40000))
    Assert.assertEquals(
      StaticUtils.toHex(Ethash.calcDataSetItem(cache, 0L, new EVMWord(40000)).take(32).toList),
      "0x6754E3B3E30274AE82A722853B35D8A2BD2347FFEE05BCBFDE4469DEB8B5D2F0"
    )
    Assert.assertEquals(
      StaticUtils.toHex(Ethash.calcDataSetItem(cache, 1337L, new EVMWord(40000)).take(32).toList),
      "0xCC8397C114C7780C491951397E41A1A1509EE0BD33949263452C786D1EEF7ACD"
    )
  }
  
  @Test
  def public void testNewHashimoto() {
    val block1 = BlockchainData.getBlockByNumber(EVMWord.ONE)
    val result = Ethash.proofOfWork(block1)
    Assert.assertEquals(new EVMWord(result.key), block1.mixHash)
    Assert.assertTrue(new BigInteger(result.value).compareTo(TWO.pow(256).divide(block1.difficulty.toBigInteger)) == -1)
    BlockchainData.flush
    DataBaseWrapper.closeAllConnections
  }
}