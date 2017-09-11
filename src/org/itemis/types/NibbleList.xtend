package org.itemis.types

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.List
import org.itemis.utils.Utils

class NibbleList {
  extension Utils u = new Utils
  
  @Accessors private List<Nibble> elements = newArrayList
  
  new() {
    
  }
  
  new(EVMWord v) {
    for (b: v.toByteArray) {
      this.elements.add(b.higherNibble)
      this.elements.add(b.lowerNibble)
    }
  }
  
  new(List<Nibble> l) {
    elements.addAll(l)
  }
  
  override equals(Object other) {
    if (other instanceof NibbleList) {
      elements.equals(other.elements)
    } else {
      false
    }
  }
  
  override hashCode() {
    elements.hashCode    
  }
  
  def Nibble head() {
    elements.get(0)
  }
  
  def NibbleList tail() {
    subList(1)
  }
  
  def boolean startsWith(NibbleList other) {
    var result = true
    
    if (other.length <= length) {
      for (var i = 0; (i < other.length) && result; i++) {
        result = other.get(i).equals(get(i))
      }
    } else {
      result = false
    }
    
    result
  }
  
  def NibbleList sharedPrefix(NibbleList other) {
    val maxLength = Math.min(length, other.length)
    
    val result = new NibbleList
    
    var differ = false
    for (var i = 0; (i < maxLength) && !differ; i++) {
      differ = !other.get(i).equals(get(i))
      if (!differ) {
        result.elements.add(get(i))
      }
    }
    
    result
  }
  
  def NibbleList unsharedSuffix(NibbleList other) {
    val maxLength = Math.min(length, other.length)
    
    var sharedLength = 0
    var same = true
    for (var i = 0; (i < maxLength) && same; i++) {
      same = other.get(i).equals(get(i))
      if (same) {
        sharedLength++
      }
    }
    
    new NibbleList(elements.subList(sharedLength, length))
  }
  
  override toString() {
    try {
      toHex(toUnsignedBytes)
    } catch (IllegalArgumentException e) {
      val copy = subList(0)
      copy.elements.add(0, new Nibble(0))
      copy.toString
    }
  }
  
  def NibbleList subList(int fromIndex) {
    new NibbleList(elements.subList(fromIndex, length))
  }
  
  def UnsignedByte[] toUnsignedBytes() {
    if (length % 2 != 0) {
      throw new IllegalArgumentException("NibbleList has odd length")
    } else {
      val result = newArrayList
      
      for (var i = 0; i < length; i += 2) {
        result.add(new UnsignedByte(get(i), get(i + 1)))
      }
      
      result
    }
  }
  
  def void add(Nibble n) {
    elements.add(n.copy)
  }
  
  def void addAll(NibbleList l) {
    elements.addAll(l.elements.map[copy])
  }
  
  def Nibble get(int i) {
    elements.get(i).copy
  }
  
  def int length() {
    elements.length
  }
  
  def int size() {
    length
  }
}