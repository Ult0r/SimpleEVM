/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.blockchain

import org.itemis.types.EVMWord
import org.eclipse.xtend.lib.annotations.Accessors

class Account {
  @Accessors private EVMWord nonce
  @Accessors private EVMWord balance
  @Accessors private EVMWord storageRoot
  @Accessors private EVMWord codeHash
}
