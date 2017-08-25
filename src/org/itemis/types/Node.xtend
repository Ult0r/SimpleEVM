package org.itemis.types

import java.util.List

class Node<T> {
  T data
  List<Node<T>> children = newArrayList
  
  new() {
    
  }
  
  new(T value) {
    data = value
  }
  
  new(List<T> values) {
    for (v: values) {
      children.add(new Node(v))        
    }
  }
  
  def T getData() {
    data
  }
  
  def void setData(T value) {
    data = value
  }
  
  def List<Node<T>> getChildren() {
    children
  }
}