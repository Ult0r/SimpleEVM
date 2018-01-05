package org.itemis.main

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import javax.net.ServerSocketFactory

final class SessionController extends Thread {
  private static final Logger LOGGER = LoggerFactory.getLogger("SessionController")
  
  def public static void main(String[] args) {
    new SessionController().run()
  }
  
  override run() {
    LOGGER.trace("creating node")
    val node = new EthereumNode()
    LOGGER.trace("node done initalizing - starting node")
    try {
      node.start
      LOGGER.trace("node started")
      
      LOGGER.trace("session controller loop started")
      val socket = ServerSocketFactory.getDefault.createServerSocket(56789)
      LOGGER.trace("session controller listening to port 56789...")
      val _socket = socket.accept
      if (_socket.inputStream.read == 42) {
        //shutdown
        println("42")
      } else {
        println("not 42")
      }
      LOGGER.trace("session controller loop done")
      
      node.interrupt
      LOGGER.trace("node done")
    } catch (InterruptedException e) {
      Thread.currentThread.interrupt
      node.interrupt
    }
  }
}