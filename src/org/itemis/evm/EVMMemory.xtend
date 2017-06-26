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

import org.itemis.evm.types.EVMWordIndexedList
import org.itemis.evm.types.EVMWord

//256-bit-word-adressed byte array
//volatile and dynamically sized
class EVMMemory {
	private final EVMWordIndexedList<Byte> elements	= new EVMWordIndexedList()
	
	def Byte get(EVMWord index) {
		elements.get(index)
	}
	
	def EVMMemory set(EVMWord index, Byte value) {
		elements.set(index, value)
		this
	}
	
	def EVMWord usedBytes() {
		elements.size
	}
}