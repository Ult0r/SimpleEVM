package org.itemis.test.ressources

import org.junit.Test
import org.itemis.ressources.DataFetch
import java.util.logging.Logger
import org.junit.BeforeClass
import org.junit.AfterClass
import org.itemis.ressources.UnsuccessfulDataFetchException
import org.itemis.utils.logging.LoggerController

class DataFetchTest {
  extension DataFetch d = new DataFetch()
  
  @BeforeClass
  def static void initLogger() {
    val Logger logger = LoggerController.createLogger(DataFetchTest)
    LoggerController.addLogger(logger)
  }
  
  @AfterClass
  def static void removeLogger() {
    LoggerController.removeLogger()
  }
  
  @Test(expected = UnsuccessfulDataFetchException)
  def void testInvalidPostData() {
    fetchData("This is not a valid request")
  }
}