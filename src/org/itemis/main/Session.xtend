package org.itemis.main

import org.itemis.blockchain.WorldState
import org.itemis.types.impl.Address
import org.itemis.blockchain.Account
import org.itemis.blockchain.Transaction
import org.itemis.evm.EVMRuntime
import org.itemis.types.impl.EVMWord
import java.util.Queue
import java.util.concurrent.ConcurrentLinkedQueue

public class Session implements Runnable {
  private final String name
  private final WorldState ws
  
  private final Queue<Transaction> transactionQueue = new ConcurrentLinkedQueue
    
  new(String name) {
    this(name, true)
  }
  
  new(String name, boolean empty) {
    this.name = name
    
    val sessionName = "session_" + name
    if (!empty) {
      SessionController.copyNode(sessionName)
    }
    this.ws = new WorldState(sessionName)
  }
  
  synchronized def public void addAccount(Address addr, Account acc) {
    ws.putAccount(ws.currentBlockNumber, addr, acc)
  }
  
  synchronized def private EVMWord executeTransaction(Transaction tx) {
    new EVMRuntime(ws).executeTransaction(tx)
  }
  
  synchronized def public void addTransactionToQueue(Transaction tx) {
    transactionQueue.add(tx)
    transactionQueue.notify
  }
  
  override run() {
    while(true) {
      transactionQueue.wait
      executeTransaction(transactionQueue.poll)
    }
  }  
}