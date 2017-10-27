package org.itemis.evm.utils

import java.util.Map
import org.itemis.types.EVMWord
import org.apache.commons.lang3.tuple.Triple
import org.itemis.blockchain.WorldState
import java.util.List

final class Patch {
  //address -> (balance, nonce, (offset -> value))
  private final Map<EVMWord, Triple<EVMWord, EVMWord, Map<EVMWord, EVMWord>>> changes = newHashMap
  
  //returns patch that undoes this patch
  def Patch applyChanges(WorldState ws) {
    //TODO
  }
  
  def void mergePatches(Patch other) {
    if (other !== null) {
      //TODO
    }
  }
  
  def static boolean hasChanged(WorldState ws, List<Patch> patches, EVMWord address) {
    //TODO
    false
  }
  
  def static EVMWord getBalance(WorldState ws, List<Patch> patches, EVMWord address) {
    //TODO
  }
  
  def static EVMWord getNonce(WorldState ws, List<Patch> patches, EVMWord address) {
    //TODO
  }
  
  def static EVMWord getStorageAt(WorldState ws, List<Patch> patches, EVMWord address, EVMWord offset) {
    //TODO
  }
}