package org.itemis.evm.utils

import org.itemis.types.UnsignedByte
import java.util.List
import org.itemis.types.Node

class EVMUtils {
  def UnsignedByte[] rlp(Object data) {
    StaticEVMUtils.rlp(data)
  }

  // recursive length prefix
  def UnsignedByte[] rlp(UnsignedByte[] data) {
    StaticEVMUtils.rlp(data)
  }

  def UnsignedByte[] rlp(List<UnsignedByte[]> data) {
    StaticEVMUtils.rlp(data)
  }

  def Node<UnsignedByte[]> reverseRLP(UnsignedByte[] data) {
    StaticEVMUtils.reverseRLP(data)
  }
}
