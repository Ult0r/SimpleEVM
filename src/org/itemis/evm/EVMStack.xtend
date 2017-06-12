package org.itemis.evm

import java.util.List
import org.itemis.evm.types.EVMWord
import java.util.ArrayList

//not using java.util.Stack because of lacking operations
class EVMStack {
	public final static int EVM_MAX_STACK_SIZE = 1024
	
	private final List<EVMWord> elements = new ArrayList(EVM_MAX_STACK_SIZE)
	
}