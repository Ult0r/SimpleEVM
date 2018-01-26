package org.itemis.main

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import java.net.URI
import org.glassfish.jersey.server.ResourceConfig
import org.glassfish.jersey.grizzly2.httpserver.GrizzlyHttpServerFactory
import java.util.logging.LogManager

final class SessionController implements Runnable {
  private static final Logger LOGGER = LoggerFactory.getLogger("SessionController")
  
  private static SessionController CONTROLLER_RUNNABLE
  private static Thread CONTROLLER
  
  private EthereumNode node
  
  def public static void main(String[] args) {
    CONTROLLER_RUNNABLE = new SessionController
    CONTROLLER = new Thread(CONTROLLER_RUNNABLE)
    CONTROLLER.start
  }
  
  def public static void shutdown() {
    CONTROLLER.interrupt
  }
  
  def public static void startNode() {
    CONTROLLER_RUNNABLE.node = new EthereumNode
    CONTROLLER_RUNNABLE.node.start
  }
  
  def public static void shutdownNode() {
    CONTROLLER_RUNNABLE.node.interrupt
  }
  
  def public static void copyNode(String destination) {
    CONTROLLER_RUNNABLE.node.copyWorldState(destination)
  }
  
  override run() {
    LogManager.logManager.reset
    
    LOGGER.trace("creating node")
    LOGGER.trace("node done initalizing - starting node")
    val ResourceConfig config = new ResourceConfig().packages("org.itemis.main")
    val server = GrizzlyHttpServerFactory.createHttpServer(URI.create("http://localhost:8080/"), config)
    LOGGER.trace("server started")
    
    try {
      LOGGER.trace("session controller loop started")
      System.out.println("go")
      
      val dummy = new Integer(0)
      synchronized(dummy) {
        dummy.wait()
      }
    } catch (InterruptedException e) {
      Thread.currentThread.interrupt
      LOGGER.trace("session controller interrupted")
      if (node !== null) node.interrupt
      server.shutdownNow
    }
  }
}