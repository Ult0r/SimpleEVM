package org.itemis.types

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.List

class UnsignedByteList {
  @Accessors private List<UnsignedByte> elements = newArrayList
  
  new() {

  }
  
  new(byte[] array) {
    this(array.map[new UnsignedByte(it)])
  }

  new(UnsignedByte[] array) {
    this.elements.addAll(array)
  }

  override equals(Object other) {
    if(other instanceof UnsignedByteList) {
      if(size == other.size) {
        for (var i = 0; i < size; i++) {
          if(!get(i).equals(other.get(i))) {
            return false
          }
        }
        return true
      } else {
        return false
      }
    } else {
      return false
    }
  }

  override hashCode() {
    elements.hashCode
  }

  def UnsignedByte get(int i) {
    elements.get(i)
  }

  def int size() {
    elements.size
  }
}