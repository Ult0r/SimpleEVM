package org.itemis.evm.types

import java.util.List
import org.itemis.evm.ListUtils

class EVMWordIndexedList<T> {
	extension ListUtils u = new ListUtils()

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
	// doesn't reserve space yet besides list-overhead
	new() {
		elements.add(newArrayList()) // b
		elements.get(0).add(newArrayList()) // c
		elements.get(0).get(0).add(newArrayList()) // d
		elements.get(0).get(0).get(0).add(newArrayList()) // e
		elements.get(0).get(0).get(0).get(0).add(newArrayList()) // f
		elements.get(0).get(0).get(0).get(0).get(0).add(newArrayList()) // g
		elements.get(0).get(0).get(0).get(0).get(0).get(0).add(newArrayList()) // h
		elements.get(0).get(0).get(0).get(0).get(0).get(0).get(0).add(newArrayList()) // i
		elements.get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).add(newArrayList()) // j
		elements.get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).add(newArrayList()) // k
		elements.get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).add(newArrayList()) // l
		elements.get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).add(newArrayList()) // m
		elements.get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).add(newArrayList()) // n
		elements.get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).add(newArrayList()) // o
		elements.get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).add(newArrayList()) // p
	}

	def EVMWordIndexedList<T> set(EVMWord index, T value) {
		var List<Integer> indices = index.convertTo16BitFieldList
		ensureIndexExists(indices)
		elements.get10(indices).get5(indices.subList(9, 15)).set(indices.get(15), value)
		this
	}

	def T get(EVMWord index) {
		try {
			var List<Integer> indices = index.convertTo16BitFieldList
			elements.get10(indices).get5(indices.subList(9, 15)).get(indices.get(15))
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
	}
}
