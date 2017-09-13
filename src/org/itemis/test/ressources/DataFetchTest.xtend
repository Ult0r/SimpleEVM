/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.test.ressources

import org.junit.Test
import org.itemis.ressources.DataFetch
import org.itemis.ressources.UnsuccessfulDataFetchException

class DataFetchTest {
  extension DataFetch d = new DataFetch()

  @Test(expected=UnsuccessfulDataFetchException)
  def void testInvalidPostData() {
    fetchData("This is not a valid request")
  }
}
