package org.itemis.types

final class EthashNonce extends ArbitraryLengthType {
  new(byte[] array) {
    super(new UnsignedByteArray(8, array))
  }
  
  new(UnsignedByteArray array) {
    super(new UnsignedByteArray(8, array))
  }
  
  def static EthashNonce fromString(String s) {
    new EthashNonce(UnsignedByteArray.fromString(8, s))
  }
  
}