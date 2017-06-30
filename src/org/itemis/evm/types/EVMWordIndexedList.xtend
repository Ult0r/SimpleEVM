/*******************************************************************************
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
* 
* Contributors:
* Lars Reimers for itemis AG
*******************************************************************************/

package org.itemis.evm.types

import java.util.List
import org.itemis.evm.utils.ListUtils

class EVMWordIndexedList<T> {
	extension ListUtils u = new ListUtils()
	
	private EVMWord size = new EVMWord()

	// indexing: elements[a][b][c][d][e][f][g][h][i][j][k][l][m][n][o][p]
	// with:
	// 0 <= _ <= 2^16 for all indices (a through p)
	// a represents the highest value bits of the 256-bit address
	// p the lowest value bits
	private final List< // a
	List< // b
	List< // c
	List< // d
	List< // e
	List< // f
	List< // g
	List< // h
	List< // i
	List< // j
	List< // k
	List< // l
	List< // m
	List< // n
	List< // o
	List< // p
	T>>>>>>>>>>>>>>>> elements = newArrayList()

	// enables spacing for 2^16 bytes of memory, usually no more will be needed
	// doesn't reserve space yet
	new() {
		
	}

	def EVMWordIndexedList<T> set(EVMWord index, T value) {
		var List<Integer> indices = index.convertTo16BitFieldList
		ensureIndexExists(indices)
		elements.get15(indices).set(indices.get(15), value)
		this
	}
		this
	}

	def T get(EVMWord index) {
		try {
			var List<Integer> indices = index.convertTo16BitFieldList
			elements.get15(indices).get(indices.get(15))
		} catch(Exception e) {
			null
		}
	}

	private def ensureIndexExists(List<Integer> indices) {
		elements.ensureNestedListIndexExists(indices.get(0))
		elements.get(indices).ensureNestedListIndexExists(indices.get(1))
		elements.get2(indices).ensureNestedListIndexExists(indices.get(2))
		elements.get3(indices).ensureNestedListIndexExists(indices.get(3))
		elements.get4(indices).ensureNestedListIndexExists(indices.get(4))
		elements.get5(indices).ensureNestedListIndexExists(indices.get(5))
		elements.get6(indices).ensureNestedListIndexExists(indices.get(6))
		elements.get7(indices).ensureNestedListIndexExists(indices.get(7))
		elements.get8(indices).ensureNestedListIndexExists(indices.get(8))
		elements.get9(indices).ensureNestedListIndexExists(indices.get(9))
		elements.get10(indices).ensureNestedListIndexExists(indices.get(10))
		elements.get11(indices).ensureNestedListIndexExists(indices.get(11))
		elements.get12(indices).ensureNestedListIndexExists(indices.get(12))
		elements.get13(indices).ensureNestedListIndexExists(indices.get(13))
		elements.get14(indices).ensureNestedListIndexExists(indices.get(14))
		elements.get15(indices).ensureListIndexExists(null, indices.get(15))
	}

	def EVMWord size() {
		elements.fold15(new EVMWord())[r, t|r.inc]
	}
}
