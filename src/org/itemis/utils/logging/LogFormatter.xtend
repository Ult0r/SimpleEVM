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

import java.util.logging.Formatter
import java.util.logging.LogRecord
import java.text.SimpleDateFormat
import java.util.Date
import org.itemis.utils.Utils

class LogFormatter extends Formatter {
  extension Utils u = new Utils
  
  override format(LogRecord record) {
    val String timestamp = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss").format(new Date(record.millis))
    val String path = String.format("%s#%s", record.sourceClassName, record.sourceMethodName)
    String.format("[%s] %s: [%s] %s\n", record.level.toString.rightPad(7), timestamp, path, record.message)
  }
}
