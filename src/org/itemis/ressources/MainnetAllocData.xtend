/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.ressources

import java.io.FileReader
import org.itemis.types.UnsignedByte
import org.itemis.utils.StaticUtils
import org.itemis.types.EVMWord
import org.itemis.evm.utils.StaticEVMUtils
import java.util.ArrayList
import java.sql.ResultSet
import java.util.Iterator
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import java.io.File
import java.util.List
import java.io.FileOutputStream
import java.io.FileInputStream
import org.itemis.utils.db.DataBaseWrapper
import org.itemis.utils.db.DataBaseWrapper.DataBaseID

abstract class MainnetAllocData {
  static extension DataBaseWrapper db = new DataBaseWrapper()
  
  private final static Logger LOGGER = LoggerFactory.getLogger("General")
  
  private final static String ALLOC_FILE = "src/org/itemis/ressources/mainnetAllocData"
  private final static String SHORTENED_ALLOC_FILE = "src/org/itemis/ressources/_mainnetAllocData"
  final static int ALLOC_SIZE = 8893

  private def static UnsignedByte[] getMainnetAllocData() {
    var result = newArrayList

    val mainnetAllocData = new FileReader(ALLOC_FILE)
    var readChar = mainnetAllocData.read

    var x = 0
    var u = 0
    var _u = 0
    var o = 0
    var n = 0

    while(readChar != -1) {
      if(readChar == 0x5C) { // '\'
        val modifier = mainnetAllocData.read
        if(modifier == 0x78) { // 'x'
          val first = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
          val second = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
          result.add(new UnsignedByte((first << 4) + second))

          x++
        } else if(modifier == 0x75) { // 'u'
          var firstHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
          var secondHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
          val first = new UnsignedByte((firstHalf << 4) + secondHalf)

          firstHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
          secondHalf = StaticUtils.fromHex(mainnetAllocData.read.byteValue as char)
          val second = new UnsignedByte((firstHalf << 4) + secondHalf)

          val tmp = new String(#[first.byteValue, second.byteValue], "UTF-16").getBytes("UTF-8").map [
            new UnsignedByte(it)
          ]

          result.addAll(tmp)

          u += 2
        } else if(modifier == 0x55) { // 'U'
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

          val tmp = new String(#[first.byteValue, second.byteValue, third.byteValue, fourth.byteValue], "UTF-32").
            getBytes("UTF-8").map[new UnsignedByte(it)]

          result.addAll(tmp)
          _u += 4
        } else if(modifier == 0x72) { // 'r'
          result.add(new UnsignedByte(0x0D))
          o++
        } else if(modifier == 0x6E) { // 'n'
          result.add(new UnsignedByte(0x0A))
          o++
        } else if(modifier == 0x62) { // 'b'
          result.add(new UnsignedByte(0x08))
          o++
        } else if(modifier == 0x76) { // 'v'
          result.add(new UnsignedByte(0x0B))
          o++
        } else if(modifier == 0x66) { // 'f'
          result.add(new UnsignedByte(0x0C))
          o++
        } else if(modifier == 0x61) { // 'a'
          result.add(new UnsignedByte(0x07))
          o++
        } else if(modifier == 0x74) { // 't'
          result.add(new UnsignedByte(0x09))
          o++
        } else if(modifier == 0x5C) { // '\'
          result.add(new UnsignedByte(0x5C))
          o++
        } else if(modifier == 0x22) { // '"'
          result.add(new UnsignedByte(0x22))
          o++
        } else {
          throw new IllegalArgumentException(modifier + " is not a known modifier")
        }
      } else {
        result.add(new UnsignedByte(readChar))
        n++
      }

      readChar = mainnetAllocData.read
    }

    mainnetAllocData.close()
    result
  }

  def static long getMainnetAllocDataSize() {
    try {
      val query = String.format(
        "SELECT COUNT(*) FROM alloc"
      )
      val result = DataBaseID.ALLOC.query(query)
      result.next
      result.getLong(1)
    } catch(Exception e) {
      0L
    }
  }
  
  def static void ensureDataIsWritten() {
    if(mainnetAllocDataSize != ALLOC_SIZE) {
      LOGGER.debug("written entries: " + mainnetAllocDataSize)
      writeMainnetAllocData
    }
  }
  
  private def static void writeMainnetAllocData() {
    val shortened = new File(SHORTENED_ALLOC_FILE) //rlp already decoded
    val List<Pair<EVMWord, EVMWord>> entries = newArrayList
    if (shortened.exists) {
      LOGGER.debug("reading from shortened")
      val fis = new FileInputStream(shortened)
      var byte[] buffer = newByteArrayOfSize(32)
      
      for (var i = 0; i < ALLOC_SIZE; i++) {
        if (fis.read(buffer) != 32) {
          throw new IllegalArgumentException("shortened file in wrong format")
        }
        val address = new EVMWord(buffer, true)
        if (fis.read(buffer) != 32) {
          throw new IllegalArgumentException("shortened file in wrong format")
        }
        val balance = new EVMWord(buffer, true)
        entries.add(Pair.of(address, balance))
      }
      
    } else {
      val data = mainnetAllocData
      LOGGER.debug("alloc data has length " + data.length)
      val tree = StaticEVMUtils.reverseRLP(data)
      
      for (c: tree.children) {
        val left = new ArrayList(c.children.get(0).data)
        while (left.length < 20) {
          left.add(0, new UnsignedByte(0))
        }
        val address = new EVMWord(left, true)
        
        val right = if (c.children.length == 2) c.children.get(1).data
        val balance = if (right === null) {
          new EVMWord(0)
        } else {
          new EVMWord(right, false)
        }
        
        entries.add(Pair.of(address, balance))
      }
      
      //write data to shortened
      val fos = new FileOutputStream(shortened)
      for (e: entries) {
        fos.write(e.key.toByteArray.map[byteValue])
        fos.write(e.value.toByteArray.map[byteValue])
      }
      fos.close
    }
    
    DataBaseID.ALLOC.createTable("alloc", "(address BINARY(32) PRIMARY KEY, balance BINARY(32) NOT NULL)")

    val conn = DataBaseID.ALLOC.connection
    for (e : entries) {
      val query = String.format(
        "INSERT INTO alloc VALUES ('%s', '%s')",
        e.key.formatForQuery,
        e.value.formatForQuery
      )
      conn.query(query)
    }
    conn.close
  }

  def static EVMWord getBalanceForAddress(EVMWord address) {
    ensureDataIsWritten

    val query = String.format(
      "SELECT * FROM alloc WHERE address = '%s'",
      address.toHexString.substring(2)
    )
    val result = DataBaseID.ALLOC.query(query)
    result.next
    new EVMWord(result.getBytes("balance"), true)
  }

  def static AllocDataIterator getMainnetAllocDataQueryIterator() {
    ensureDataIsWritten

    val query = String.format(
      "SELECT * FROM alloc"
    )
    new AllocDataIterator(DataBaseID.ALLOC.query(query))
  }

  public static class AllocDataIterator implements Iterator<Pair<EVMWord, EVMWord>> {
    private final ResultSet set

    protected new(ResultSet set) {
      this.set = set
    }

    override hasNext() {
      !set.isLast()
    }

    override next() {
      set.next
      val address = set.getBytes("address")
      val balance = set.getBytes("balance")
      Pair.of(
        new EVMWord(address.map[new UnsignedByte(it)], true),
        new EVMWord(balance.map[new UnsignedByte(it)], true)
      )
    }

  }
}
