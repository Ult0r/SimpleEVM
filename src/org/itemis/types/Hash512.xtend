/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.types

final class Hash512 extends ArbitraryLengthType {
  new() {
    super(new UnsignedByteArray(64))
  }

  new(byte[] array) {
    super(new UnsignedByteArray(64, array))
  }
}
