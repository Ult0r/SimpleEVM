package org.itemis.test.evm

import javax.inject.Inject
import org.itemis.evm.Utils
import org.junit.Test
import org.junit.Assert

class UtilsTest {
	@Inject extension Utils

	@Test
	def void testGetNthByteOfInteger() {
		//TODO
		var Integer zero = 0;
		Assert.assertEquals(zero.getNthByteOfInteger(0 as byte), 0)
		Assert.assertEquals(zero.getNthByteOfInteger(1 as byte), 0)
		Assert.assertEquals(zero.getNthByteOfInteger(2 as byte), 0)
		Assert.assertEquals(zero.getNthByteOfInteger(3 as byte), 0)

		var Integer test = ((3 * 255 + 2) * 255 + 1) * 255
		Assert.assertEquals(test.getNthByteOfInteger(0 as byte), 0)
		Assert.assertEquals(test.getNthByteOfInteger(1 as byte), 1)
		Assert.assertEquals(test.getNthByteOfInteger(2 as byte), 2)
		Assert.assertEquals(test.getNthByteOfInteger(3 as byte), 3)
	}
}
