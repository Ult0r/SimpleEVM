package org.itemis.evm.types

import java.util.List

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
		elements.get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).add(
			newArrayList()) // o
		elements.get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).get(0).add(
			newArrayList()) // p
	}
}