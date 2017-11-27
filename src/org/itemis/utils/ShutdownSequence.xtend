package org.itemis.utils

import java.util.Set
import java.util.Comparator
import org.slf4j.LoggerFactory
import org.slf4j.Logger
import org.apache.logging.log4j.LogManager
import org.apache.logging.log4j.core.config.Configurator
import org.apache.logging.log4j.core.LoggerContext

final class ShutdownSequence extends Thread {
  private static final Logger LOGGER = LoggerFactory.getLogger("Shutdown")
  
  private static final ShutdownSequence seq = {
    val s = new ShutdownSequence()
    Runtime.runtime.addShutdownHook(s)
    s  
  }
  
  private final Set<Pair<Shutdownable, Integer>> shutdownInstances = newHashSet
  private final Set<Pair<Class<?>, Integer>> shutdownClasses = newHashSet
  
  //Priority: 0-20, 0 is highest, 20 is lowest, 10 is default
  
  override run() {
    LOGGER.info("starting shutdown sequence")
    for (s: shutdownInstances.sortWith(new Comparator<Pair<Shutdownable, Integer>> {
      override compare(Pair<Shutdownable, Integer> o1, Pair<Shutdownable, Integer> o2) {
        o1.value.compareTo(o2.value)
      }
    })) {
      LOGGER.info(String.format("shutting down %s", s.key.toString))
      try {
        s.key.shutdown
      } catch (Exception e) {
        //do nothing
      }
    }
    for (c: shutdownClasses.sortWith(new Comparator<Pair<Class<?>, Integer>> {
      override compare(Pair<Class<?>, Integer> o1, Pair<Class<?>, Integer> o2) {
        o1.value.compareTo(o2.value)
      }
    })) {
      try {
        LOGGER.info(String.format("trying to shut down %s", c.key.toString))
        c.key.getMethod("shutdown").invoke(null)
      } catch (Exception e) {
        LOGGER.info(String.format("shutting down %s failed", c.key.toString))
      }
    }
    LOGGER.info("done shutting down")
    LOGGER.info("shutting down logging now")
    Configurator.shutdown(LogManager.context as LoggerContext)
  }
  
  def static void registerShutdownInstance(Shutdownable s) {
    registerShutdownInstance(s, 10)
  }
  
  def static void registerShutdownInstance(Shutdownable s, Integer p) {
    LOGGER.info(String.format("registering %s for shutdown", s.toString))
    seq.shutdownInstances.add(Pair.of(s, p))
  }
  
  def static void registerShutdownClass(Class<?> c) {
    registerShutdownClass(c, 10)  
  }
  
  def static void registerShutdownClass(Class<?> c, Integer p) {
    LOGGER.info(String.format("registering %s for shutdown", c.toString))
    seq.shutdownClasses.add(Pair.of(c, p))
  }
  
  def static Thread getShutdownSequence() {
    seq
  }
}
