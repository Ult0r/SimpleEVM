/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.types.impl

import org.itemis.types.UnsignedByteArray
import org.itemis.types.ArbitraryLengthType

final class EthashNonce extends ArbitraryLengthType {
  new(byte[] array) {
    super(new UnsignedByteArray(8, array))
  }

  new(UnsignedByteArray array) {
    super(new UnsignedByteArray(8, array))
  }

  def static EthashNonce fromString(String s) {
    new EthashNonce(UnsignedByteArray.fromString(8, s))
  }

}
