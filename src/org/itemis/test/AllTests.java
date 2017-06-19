package org.itemis.test;

import org.itemis.test.evm.UtilsTest;
import org.itemis.test.evm.types.EVMWordTest;
import org.itemis.test.evm.types.UnsignedByteTest;
import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

@RunWith(Suite.class)
@SuiteClasses({
  UnsignedByteTest.class,
  UtilsTest.class,
  EVMWordTest.class
})
public class AllTests {

}
