/*******************************************************************************
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
* 
* Contributors:
* Lars Reimers for itemis AG
*******************************************************************************/

package org.itemis.test;

import org.itemis.test.evm.types.EVMWordTest;
import org.itemis.test.evm.types.UnsignedByteTest;
import org.itemis.test.evm.utils.EVMWordIndexedListTest;
import org.itemis.test.evm.utils.UtilsTest;
import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({
  UnsignedByteTest.class,
  UtilsTest.class,
  EVMWordTest.class,
  EVMWordIndexedListTest.class
})
public class AllTests {

}
