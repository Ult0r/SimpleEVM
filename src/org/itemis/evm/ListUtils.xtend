package org.itemis.evm

import java.util.List

class ListUtils {
	def <T extends Object> ensureListIndexExists(List<T> list, T fillValue, int index) {
		ensureListLength(list, fillValue, index + 1)
	}

	def <T extends Object> ensureListLength(List<T> list, T fillValue, int length) {
		while(list.length < length) {
			list.add(fillValue)
		}
	}

	def <T extends Object> ensureNestedListIndexExists(List<List<T>> list, int index) {
		ensureNestedListLength(list, index + 1)
	}

	def <T extends Object> ensureNestedListLength(List<List<T>> list, int length) {
		while(list.length < length) {
			list.add(newArrayList())
		}
	}

	def <T extends Object> T get(T list) {
		list
	}

	def <T extends Object> T get(List<T> list, int a) {
		list.get(a)
	}

	def <T extends Object> T get(List<List<T>> list, int a, int b) {
		list.get(a).get(b)
	}

	def <T extends Object> T get(List<List<List<T>>> list, int a, int b, int c) {
		list.get(a, b).get(c)
	}

	def <T extends Object> T get(List<List<List<List<T>>>> list, int a, int b, int c, int d) {
		list.get(a, b, c).get(d)
	}

	def <T extends Object> T get(List<List<List<List<List<T>>>>> list, int a, int b, int c, int d, int e) {
		list.get(a, b, c, d).get(e)
	}

	def <T extends Object> T get(List<List<List<List<List<List<T>>>>>> list, int a, int b, int c, int d,
		int e, int f) {
		list.get(a, b, c, d, e).get(f)
	}

	def <T extends Object> T get(List<List<List<List<List<List<List<T>>>>>>> list, int a, int b, int c,
		int d, int e, int f, int g) {
		list.get(a, b, c, d, e, f).get(g)
	}

	def <T extends Object> T get(List<List<List<List<List<List<List<List<T>>>>>>>> list, int a, int b,
		int c, int d, int e, int f, int g, int h) {
		list.get(a, b, c, d, e, f, g).get(h)
	}

	def <T extends Object> T get(List<List<List<List<List<List<List<List<List<T>>>>>>>>> list, int a, int b,
		int c, int d, int e, int f, int g, int h, int i) {
		list.get(a, b, c, d, e, f, g, h).get(i)
	}

	def <T extends Object> T get(List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>> list, int a,
		int b, int c, int d, int e, int f, int g, int h, int i, int j) {
		list.get(a, b, c, d, e, f, g, h, i).get(j)
	}
	def <T extends Object> T get(T list, List<Integer> indices) {
		list
	}

	def <T extends Object> T get(List<T> list, List<Integer> indices) {
		if(indices.size >= 1) {
			list.get(indices.get(0))
		} else {
			throw new IllegalArgumentException("indices list is not long enough")
		}
	}

	def <T extends Object> T get2(List<List<T>> list, List<Integer> indices) {
		if(indices.size >= 2) {
			list.get(indices.get(0), indices.get(1))
		} else {
			throw new IllegalArgumentException("indices list is not long enough")
		}
	}

	def <T extends Object> T get3(List<List<List<T>>> list, List<Integer> indices) {
		if(indices.size >= 3) {
			list.get(indices.get(0), indices.get(1), indices.get(2))
		} else {
			throw new IllegalArgumentException("indices list is not long enough")
		}
	}

	def <T extends Object> T get4(List<List<List<List<T>>>> list, List<Integer> indices) {
		if(indices.size >= 4) {
			list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3))
		} else {
			throw new IllegalArgumentException("indices list is not long enough")
		}
	}

	def <T extends Object> T get5(List<List<List<List<List<T>>>>> list, List<Integer> indices) {
		if(indices.size >= 5) {
			list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4))
		} else {
			throw new IllegalArgumentException("indices list is not long enough")
		}
	}

	def <T extends Object> T get6(List<List<List<List<List<List<T>>>>>> list, List<Integer> indices) {
		if(indices.size >= 6) {
			list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5))
		} else {
			throw new IllegalArgumentException("indices list is not long enough")
		}
	}

	def <T extends Object> T get7(List<List<List<List<List<List<List<T>>>>>>> list, List<Integer> indices) {
		if(indices.size >= 7) {
			list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5), indices.get(6))
		} else {
			throw new IllegalArgumentException("indices list is not long enough")
		}
	}

	def <T extends Object> T get8(List<List<List<List<List<List<List<List<T>>>>>>>> list, List<Integer> indices) {
		if(indices.size >= 8) {
			list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5), indices.get(6), indices.get(7))
		} else {
			throw new IllegalArgumentException("indices list is not long enough")
		}
	}

	def <T extends Object> T get9(List<List<List<List<List<List<List<List<List<T>>>>>>>>> list, List<Integer> indices) {
		if(indices.size >= 9) {
			list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5), indices.get(6), indices.get(7),
				indices.get(8))
		} else {
			throw new IllegalArgumentException("indices list is not long enough")
		}
	}

	def <T extends Object> T get10(List<List<List<List<List<List<List<List<List<List<T>>>>>>>>>> list, List<Integer> indices) {
		if (indices.size >= 10) {
			list.get(indices.get(0), indices.get(1), indices.get(2), indices.get(3), indices.get(4), indices.get(5), indices.get(6), indices.get(7), indices.get(8), indices.get(9))
		} else {
			throw new IllegalArgumentException("indices list is not long enough")
		}
	}
}
