package org.itemis.test.ressources

import org.junit.Test
import org.itemis.ressources.DataFetch

class DataFetchTest {
  extension DataFetch d = new DataFetch()
  
  @Test(expected = IllegalArgumentException)
  def void testInvalidPostData() {
    fetchData("This is not valid Json")
  }
}