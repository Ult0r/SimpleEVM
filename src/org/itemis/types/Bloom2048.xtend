package org.itemis.types

final class Bloom2048 extends ArbitraryLengthType {
  new() {
    super(new UnsignedByteArray(256))
  }
  
  new(int i) {
    super(new UnsignedByteArray(256).setInt(i))
  }
  
  new(byte[] array) {
    super(new UnsignedByteArray(256, array))
  }
  
  new(UnsignedByteArray array) {    
    super(new UnsignedByteArray(256, array))
  }
  
  def static Bloom2048 fromString(String s) {
    new Bloom2048(UnsignedByteArray.fromString(256, s))
  }
}