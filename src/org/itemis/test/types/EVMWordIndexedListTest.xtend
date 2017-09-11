/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/

package org.itemis.test.types

import org.itemis.types.EVMWordIndexedList
import org.junit.Test
import org.junit.Assert
import org.itemis.types.EVMWord

class EVMWordIndexedListTest {
  @Test
  def void testList() {
    var list = new EVMWordIndexedList<Integer>
    Assert.assertEquals(list.toString, "")
    Assert.assertEquals(list.size, new EVMWord(0))

    list.add(42)
    Assert.assertEquals(list.toString, "42\n")
    Assert.assertEquals(list.size, new EVMWord(1))

    list.add(1337)
    Assert.assertEquals(list.toString, "42\n1337\n")
    Assert.assertEquals(list.size, new EVMWord(2))

    list.remove(new EVMWord(0))
    Assert.assertEquals(list.toString, "1337\n")
    Assert.assertEquals(list.size, new EVMWord(1))

    list.remove(new EVMWord(0))
    Assert.assertEquals(list.toString, "")
    Assert.assertEquals(list.size, new EVMWord(0))
  }
}
