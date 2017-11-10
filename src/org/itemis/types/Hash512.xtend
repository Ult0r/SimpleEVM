package org.itemis.types

final class Hash512 extends ArbitraryLengthType {
  new() {
    super(new UnsignedByteArray(64))
  }
  
  new(byte[] array) {
    super(new UnsignedByteArray(64, array))
  }
}