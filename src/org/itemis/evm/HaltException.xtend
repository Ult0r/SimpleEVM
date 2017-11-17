package org.itemis.evm

import java.lang.Exception

class HaltException extends Exception {
  new(String string) {
    super(string)
  }
}