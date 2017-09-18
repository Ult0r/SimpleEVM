/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.evm.utils

import org.itemis.types.UnsignedByte
import java.util.List
import org.itemis.types.Node
import java.util.function.Predicate

class EVMUtils {
  // recursive length prefix
  def UnsignedByte[] rlp(UnsignedByte[] data) {
    StaticEVMUtils.rlp(data)
  }

  def UnsignedByte[] rlp(List<UnsignedByte[]> data) {
    StaticEVMUtils.rlp(data)
  }

  def UnsignedByte[] rlp(List<UnsignedByte[]> data, boolean resolveChildren) {
    StaticEVMUtils.rlp(data, resolveChildren)
  }

  def UnsignedByte[] rlp(List<UnsignedByte[]> data, Predicate<UnsignedByte[]> resolveChildren) {
    StaticEVMUtils.rlp(data, resolveChildren)
  }

  def Node<UnsignedByte[]> reverseRLP(UnsignedByte[] data) {
    StaticEVMUtils.reverseRLP(data)
  }

  def boolean isValidRLP(UnsignedByte[] data) {
    StaticEVMUtils.isValidRLP(data)
  }
}
