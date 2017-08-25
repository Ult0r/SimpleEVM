/*******************************************************************************
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
* 
* Contributors:
* Lars Reimers for itemis AG
*******************************************************************************/

package org.itemis.evm

import org.itemis.types.EVMWordIndexedList
import org.itemis.types.EVMWord

//256-bit-word-adressed byte array
//volatile and dynamically sized
class EVMStorage {
	private final EVMWordIndexedList<EVMWord> elements	= new EVMWordIndexedList()
	
	def EVMWord get(EVMWord index) {
		elements.get(index)
	}
	
	def EVMStorage set(EVMWord index, EVMWord value) {
		elements.set(index, value)
		this
	}
	
	def EVMWord usedBytes() {
		elements.size
	}
}