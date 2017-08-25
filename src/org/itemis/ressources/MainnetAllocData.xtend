package org.itemis.ressources

import java.io.FileReader
import org.itemis.evm.types.UnsignedByte
import org.itemis.evm.utils.StaticUtils
import java.util.List
import org.itemis.evm.types.Node
import org.itemis.evm.types.EVMWord
import java.util.Map

abstract class MainnetAllocData {
	private static List<UnsignedByte> MAINNET_ALLOC_DATA
	private static Node<UnsignedByte[]> MAINNET_ALLOC_DATA_TREE
	
  def static UnsignedByte[] getMainnetAllocData() {
  	if (MAINNET_ALLOC_DATA === null) {
      MAINNET_ALLOC_DATA = newArrayList
  
      val mainnetAllocData = new FileReader('ressources/mainnetAllocData')
      var readChar = mainnetAllocData.read
      
      var x = 0
      var u = 0
      var _u = 0
      var o = 0
      var n = 0
      
      while(readChar != -1) {
        if(readChar == 0x5C) { // '\'
          val modifier = mainnetAllocData.read
          if (modifier == 0x78) { // 'x'
            val first = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
            val second = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
            MAINNET_ALLOC_DATA.add(new UnsignedByte((first << 4) + second))
            
            x++
          } else if (modifier == 0x75) { // 'u'
            var firstHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
            var secondHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
            val first = new UnsignedByte((firstHalf << 4) + secondHalf)
            
            firstHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
            secondHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
            val second = new UnsignedByte((firstHalf << 4) + secondHalf)
            
            val tmp = new String(#[first.byteValue, second.byteValue], "UTF-16").getBytes("UTF-8").map[new UnsignedByte(it)]
            
            MAINNET_ALLOC_DATA.addAll(tmp)
            
            u+=2
          } else if (modifier == 0x55) { // 'U'
            var firstHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
            var secondHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
            val first = new UnsignedByte((firstHalf << 4) + secondHalf)
            
            firstHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
            secondHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
            val second = new UnsignedByte((firstHalf << 4) + secondHalf)
            
            firstHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
            secondHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
            val third = new UnsignedByte((firstHalf << 4) + secondHalf)
            
            firstHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
            secondHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
            val fourth = new UnsignedByte((firstHalf << 4) + secondHalf)
            
            
            val tmp = new String(#[first.byteValue, second.byteValue, third.byteValue, fourth.byteValue], "UTF-32").getBytes("UTF-8").map[new UnsignedByte(it)]
            
            MAINNET_ALLOC_DATA.addAll(tmp)
            _u+=4
          } else if (modifier == 0x72) { // 'r'
          	MAINNET_ALLOC_DATA.add(new UnsignedByte(0x0D))
          	o++
          } else if (modifier == 0x6E) { // 'n'
            MAINNET_ALLOC_DATA.add(new UnsignedByte(0x0A))
            o++
          } else if (modifier == 0x62) { // 'b'
            MAINNET_ALLOC_DATA.add(new UnsignedByte(0x08))
            o++
          } else if (modifier == 0x76) { // 'v'
            MAINNET_ALLOC_DATA.add(new UnsignedByte(0x0B))
            o++
          } else if (modifier == 0x66) { // 'f'
            MAINNET_ALLOC_DATA.add(new UnsignedByte(0x0C))
            o++
          } else if (modifier == 0x61) { // 'a'
            MAINNET_ALLOC_DATA.add(new UnsignedByte(0x07))
            o++
          } else if (modifier == 0x74) { // 't'
            MAINNET_ALLOC_DATA.add(new UnsignedByte(0x09))
            o++
          } else if (modifier == 0x5C) { // '\'
            MAINNET_ALLOC_DATA.add(new UnsignedByte(0x5C))
            o++
          } else if (modifier == 0x22) { // '"'
            MAINNET_ALLOC_DATA.add(new UnsignedByte(0x22))
            o++
          } else {
            throw new IllegalArgumentException(modifier + " is not a known modifier") 
          }
        } else {
        	MAINNET_ALLOC_DATA.add(new UnsignedByte(readChar))
        	n++
        }
  
        readChar = mainnetAllocData.read
      }
  
      mainnetAllocData.close()
      
    }
    MAINNET_ALLOC_DATA
  }
  
  def static Node<UnsignedByte[]> getMainnetAllocDataTree() {
    if (MAINNET_ALLOC_DATA_TREE === null) {
      MAINNET_ALLOC_DATA_TREE = StaticUtils.reverseRLP(mainnetAllocData)
    }
    MAINNET_ALLOC_DATA_TREE
  }
  
  def static Map<EVMWord, EVMWord> getMainnetAllocDataMap() {
    val result = newHashMap()
    
    for (c: mainnetAllocDataTree.children) {
      val address = new EVMWord(c.children.get(0).data, false)
      var EVMWord balance
      
      if (c.children.length == 2) {
        balance = new EVMWord(c.children.get(1).data, false)
      } else {
        balance = new EVMWord(0)
      }
      
      result.put(address, balance)
    }
    
    result
  }
}
