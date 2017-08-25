package org.itemis.ressources

import java.lang.Exception

class UnsuccessfulDataFetchException extends Exception {
  new(String string) {
    super(string)
  }
}