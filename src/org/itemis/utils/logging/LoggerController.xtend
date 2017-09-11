/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.utils.logging

import java.util.Stack
import java.util.logging.Logger
import java.util.logging.Level
import java.util.logging.FileHandler
import java.util.Locale
import java.io.File
import java.util.logging.LogManager
import org.itemis.utils.StaticUtils

final class LoggerController {
  private static Stack<Logger> loggerStack = new Stack
  private static Logger loggerControllerLogger = {
    Locale.setDefault(Locale.ENGLISH)

    StaticUtils.ensureDirExists("log")

    LogManager.getLogManager().reset()

    loggerStack.push(_createLogger("general"))

    val String name = LoggerController.extractClassName
    _createLogger(name)
  }

  def private static Logger _createLogger(String name) {
    val Logger logger = Logger.getLogger(name)

    logger.useParentHandlers = false
    logger.setLevel(Level.INFO)
    val file = new FileHandler("log" + File.separator + name + ".log")
    file.setFormatter(new LogFormatter())
    logger.addHandler(file)
    logger
  }

  def static String extractClassName(Class<?> _class) {
    _class.toString.split(" ").get(1)
  }

  def static Logger createLogger(Class<?> _class) {
    createLogger(_class.extractClassName)
  }

  def static Logger createLogger(String name) {
    val logger = _createLogger(name)
    loggerControllerLogger.logp(Level.INFO, LoggerController.extractClassName, "createLogger",
      "logger created: " + name)
    logger
  }

  def static Logger getLogger() {
    if(loggerStack.empty()) {
      loggerControllerLogger.logp(Level.WARNING, LoggerController.extractClassName, "getLogger", "accessed empty Stack")
      Logger.anonymousLogger
    } else {
      loggerStack.peek
    }
  }

  def static void addLogger(Logger l) {
    loggerControllerLogger.logp(Level.INFO, LoggerController.extractClassName, "addLogger", "logger added: " + l.name)
    loggerStack.push(l)
  }

  def static void removeLogger() {
    if(!loggerStack.empty()) {
      loggerControllerLogger.logp(Level.INFO, LoggerController.extractClassName, "removeLogger",
        "logger removed: " + getLogger.name)
      for (h : loggerStack.pop.handlers) {
        h.close
      }
    } else {
      loggerControllerLogger.logp(Level.WARNING, LoggerController.extractClassName, "removeLogger",
        "accessed empty Stack")
    }
  }

  def static void logFine(Class<?> sourceClass, String sourceMethod, String msg) {
    logFine(sourceClass.extractClassName, sourceMethod, msg)
  }

  def static void logFine(String sourceClass, String sourceMethod, String msg) {
    log(Level.FINE, sourceClass, sourceMethod, msg)
  }

  def static void logInfo(Class<?> sourceClass, String sourceMethod, String msg) {
    logInfo(sourceClass.extractClassName, sourceMethod, msg)
  }

  def static void logInfo(String sourceClass, String sourceMethod, String msg) {
    log(Level.INFO, sourceClass, sourceMethod, msg)
  }

  def static void logWarning(Class<?> sourceClass, String sourceMethod, String msg) {
    logWarning(sourceClass.extractClassName, sourceMethod, msg)
  }

  def static void logWarning(String sourceClass, String sourceMethod, String msg) {
    log(Level.WARNING, sourceClass, sourceMethod, msg)
  }

  def static void logSevere(Class<?> sourceClass, String sourceMethod, String msg) {
    logSevere(sourceClass.extractClassName, sourceMethod, msg)
  }

  def static void logSevere(String sourceClass, String sourceMethod, String msg) {
    log(Level.SEVERE, sourceClass, sourceMethod, msg)
  }

  def static void log(Level level, String sourceClass, String sourceMethod, String msg) {
    getLogger.logp(level, sourceClass, sourceMethod, msg)
  }
}
