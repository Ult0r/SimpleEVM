package org.itemis.types

final class Hash256 extends ArbitraryLengthType {
  public static final Hash256 ZERO = new Hash256()
  
  new() {
    super(new UnsignedByteArray(32))
  }
  
  new(byte[] array) {
    super(new UnsignedByteArray(32, array))
  }
  
  new(UnsignedByte[] array) {
    super(new UnsignedByteArray(32, array))
  }
  
  new(UnsignedByteArray array) {
    super(new UnsignedByteArray(32, array))
  }
  
  def static Hash256 fromString(String s) {
    new Hash256(UnsignedByteArray.fromString(32, s))
  }
}