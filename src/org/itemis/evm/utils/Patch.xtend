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

import java.util.Map
import org.itemis.types.impl.EVMWord
import org.apache.commons.lang3.tuple.Triple
import org.itemis.blockchain.WorldState
import java.util.Set
import org.itemis.types.impl.Address

final class Patch {
  // address -> (balance, nonce, (offset -> value))
  private final Map<Address, Triple<EVMWord, EVMWord, Map<EVMWord, EVMWord>>> changes = newHashMap
  private final Set<Address> selfDestructSet = newHashSet

  def void clear() {
    changes.clear
  }

  // returns patch that undoes this patch
  def Patch applyChanges(WorldState ws) {
    val result = new Patch()
    for (acc : changes.entrySet) {
      val addr = acc.key
      val oldAccount = ws.getAccount(addr)

      result.setBalance(addr, oldAccount.balance)
      result.setNonce(addr, oldAccount.nonce)

      for (cell : acc.value.right.entrySet) {
        if(!ws.getStorageAt(addr, cell.key).equals(cell.value)) {
          result.setStorageValue(addr, cell.key, cell.value)
        }
      }

      oldAccount.balance = acc.value.left
      oldAccount.balance = acc.value.middle
      ws.setAccount(addr, oldAccount)

      for (cell : acc.value.right.entrySet) {
        ws.setStorageAt(addr, cell.key, cell.value)
      }
    }

    for (addr : selfDestructSet) {
      val oldAccount = ws.getAccount(addr)

      result.setBalance(addr, oldAccount.balance)
      result.setNonce(addr, oldAccount.nonce)

      for (cell : ws.getStorage(addr).entrySet) {
        result.setStorageValue(addr, cell.key, cell.value)
      }

      ws.deleteAccount(addr)
    }

    result
  }
  
  def Patch mergeOtherPatch(Patch other) {
    val result = new Patch()
    
    result.changes.putAll(changes)
    result.changes.putAll(other.changes)
    
    result
  }

  def void setBalance(Address address, EVMWord balance) {
    if(changes.containsKey(address)) {
      val currentValue = changes.get(address)
      changes.put(address, Triple.of(balance, currentValue.middle, currentValue.right))
    } else {
      changes.put(address, Triple.of(balance, null, newHashMap))
    }
  }

  def void addBalance(WorldState ws, Address address, EVMWord balance) {
    setBalance(address, getBalance(ws, address).add(balance))
  }

  def void subtractBalance(WorldState ws, Address address, EVMWord balance) {
    setBalance(address, getBalance(ws, address).sub(balance))
  }

  def void setNonce(Address address, EVMWord nonce) {
    if(changes.containsKey(address)) {
      val currentValue = changes.get(address)
      changes.put(address, Triple.of(currentValue.left, nonce, currentValue.right))
    } else {
      changes.put(address, Triple.of(null, nonce, newHashMap))
    }
  }

  def void setStorageValue(Address address, EVMWord offset, EVMWord value) {
    if(changes.containsKey(address)) {
      val currentValue = changes.get(address)
      currentValue.right.put(offset, value)
    } else {
      val storageMap = newHashMap
      storageMap.put(offset, value)
      changes.put(address, Triple.of(null, null, storageMap))
    }
  }

  def boolean hasChanged(Address address) {
    return changes.containsKey(address)
  }
  
  def boolean accountExists(WorldState ws, Address address) {
    return changes.containsKey(address) || ws.accountExists(address)
  }

  def EVMWord getBalance(WorldState ws, Address address) {
    val changesVal = changes.get(address)
    if(changesVal !== null && changesVal.left !== null) {
      changesVal.left
    } else {
      ws.getBalance(address)
    }
  }

  def EVMWord getNonce(WorldState ws, Address address) {
    val changesVal = changes.get(address)
    if(changesVal !== null && changesVal.middle !== null) {
      changesVal.middle
    } else {
      ws.getNonce(address)
    }
  }

  def EVMWord getStorageAt(WorldState ws, Address address, EVMWord offset) {
    val changesVal = changes.get(address)
    if(changesVal !== null) {
      val storageValue = changesVal.right.get(offset)
      if(storageValue !== null) {
        storageValue
      } else {
        ws.getStorageAt(address, offset)
      }
    } else {
      ws.getStorageAt(address, offset)
    }
  }
}
