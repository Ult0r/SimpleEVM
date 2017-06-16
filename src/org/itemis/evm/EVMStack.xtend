package org.itemis.evm

import java.util.List
import org.itemis.evm.types.EVMWord
import java.util.ArrayList

//not using java.util.Stack because of lacking operations
class EVMStack {
	public final static int EVM_MAX_STACK_SIZE = 1024
	
	//index 0 = top
	private final List<EVMWord> elements = new ArrayList(EVM_MAX_STACK_SIZE)
	
	def void push(EVMWord word) {
		elements.add(0, word)
	}
	
	def EVMWord pop() {
		elements.remove(0)
	}
	
	def void clear() {
		elements.clear
	}
	
	def EVMWord get(int index) {
		elements.get(index)
	}
}