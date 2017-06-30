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

import org.itemis.evm.types.EVMWord

class Block {
	private EVMWord parentHash
	private EVMWord ommersListRLPHash
	private EVMWord beneficiaryAddress //only 160 bits used
	
}