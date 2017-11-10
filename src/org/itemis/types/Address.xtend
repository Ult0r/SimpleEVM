package org.itemis.types

final class Address extends ArbitraryLengthType {
  public static final Address ZERO = new Address()
  
  new() {
    super(new UnsignedByteArray(20))
  }
  
  new(byte[] array) {
    super(new UnsignedByteArray(20, array))
  }
  
  new(UnsignedByteArray array) {
    super(new UnsignedByteArray(20, array))
  }
  
  new(EVMWord word) {
    super(new UnsignedByteArray(20, word.toUnsignedByteArray))
  }
  
  def static Address fromString(String s) {
    new Address(UnsignedByteArray.fromString(20, s))
  }
}