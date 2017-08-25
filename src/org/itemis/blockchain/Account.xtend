package org.itemis.blockchain

import org.itemis.types.EVMWord
import org.eclipse.xtend.lib.annotations.Accessors

class Account {
	@Accessors private EVMWord nonce
	@Accessors private EVMWord balance
	@Accessors private EVMWord storageRoot
	@Accessors private EVMWord codeHash
}