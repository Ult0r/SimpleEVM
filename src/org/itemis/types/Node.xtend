/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
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
    for (v : values) {
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
