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
import org.itemis.evm.types.Int2048
import org.itemis.evm.utils.StaticUtils
import java.util.List

class Block {
	private EVMWord parentHash
	private EVMWord ommersHash
	private EVMWord beneficiary // only 160 bits used
	private EVMWord stateRoot
	private EVMWord transactionsRoot
	private EVMWord receiptsRoot
	private Int2048 logsBloom
	private EVMWord difficulty
	private EVMWord number
	private EVMWord gasUsed
	private EVMWord gasLimit
	private EVMWord timestamp // second since The Epoch
	private EVMWord extraData
	private EVMWord mixHash
	private EVMWord nonce // 64-bit hash
	private List<EVMWord> ommers
//	private List<Transaction> transactions //TODO: implement blockchain.Transaction
	
}