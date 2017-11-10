package org.itemis.types

abstract class ArbitraryLengthType {
  private final UnsignedByteArray array
  
  new(UnsignedByteArray array) {
    this.array = array
  }
  
  def byte[] toByteArray() {
    array.toByteArray
  }
  
  def UnsignedByte[] toUnsignedByteArray() {
    array.toUnsignedByteArray
  }
  
  override String toString() {
    toHexString
  }
  
  def String toHexString() {
    array.toHexString
  }
  
  def EVMWord toEVMWord() {
    new EVMWord(new UnsignedByteArray(32, array))
  }
  
  override boolean equals(Object other) {
    if (other instanceof ArbitraryLengthType) {
      array.equals(other.array)
    } else {
      false
    }
  }
}