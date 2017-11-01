package org.itemis.evm.utils

import java.util.Map
import org.itemis.types.EVMWord
import org.apache.commons.lang3.tuple.Triple
import org.itemis.blockchain.WorldState

final class Patch {
  //address -> (balance, nonce, (offset -> value))
  private final Map<EVMWord, Triple<EVMWord, EVMWord, Map<EVMWord, EVMWord>>> changes = newHashMap
  
  //returns patch that undoes this patch
  def Patch applyChanges(WorldState ws) {
    //TODO
  }
  
  def void setBalance(EVMWord address, EVMWord balance) {
    if (changes.containsKey(address)) {
      val currentValue = changes.get(address)
      changes.put(address, Triple.of(balance, currentValue.middle, currentValue.right))
    } else {
      changes.put(address, Triple.of(balance, null, newHashMap))
    }
  }
  
  def void setNonce(EVMWord address, EVMWord nonce) {
    if (changes.containsKey(address)) {
      val currentValue = changes.get(address)
      changes.put(address, Triple.of(currentValue.left, nonce, currentValue.right))
    } else {
      changes.put(address, Triple.of(null, nonce, newHashMap))
    }
  }
  
  def void setStorageValue(EVMWord address, EVMWord offset, EVMWord value) {
    if (changes.containsKey(address)) {
      val currentValue = changes.get(address)
      currentValue.right.put(offset, value)
    } else {
      val storageMap = newHashMap
      storageMap.put(offset, value)
      changes.put(address, Triple.of(null, null, storageMap))
    }
  }
  
  def boolean hasChanged(EVMWord address) {
    return changes.containsKey(address)
  }
  
  def EVMWord getBalance(WorldState ws, EVMWord address) {
    //TODO
  }
  
  def EVMWord getNonce(WorldState ws, EVMWord address) {
    //TODO
  }
  
  def EVMWord getStorageAt(WorldState ws, EVMWord address, EVMWord offset) {
    //TODO
  }
}