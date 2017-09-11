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
import java.sql.Connection
import org.itemis.utils.logging.LoggerController
import java.io.File
import java.sql.DriverManager
import java.sql.ResultSet
import java.util.Iterator

abstract class MainnetAllocData {
  private final static String ALLOC_FILE = "mainnetAllocData"
  final static int ALLOC_SIZE = 8893

  def static UnsignedByte[] getMainnetAllocData() {
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

  def static Connection getMainnetAllocDataConn() {
    val path = "db" + File.separator + "alloc" + File.separator + "data"
    DriverManager.getConnection("jdbc:hsqldb:file:" + path, "SA", "")
  }

  def static long getMainnetAllocDataSize() {
    try {
      val query = String.format(
        "SELECT COUNT(*) FROM alloc"
      )
      val conn = mainnetAllocDataConn
      val result = conn.prepareStatement(query).executeQuery
      result.next
      val _result = result.getLong(1)
      conn.close
      _result
    } catch(Exception e) {
      0L
    }
  }

  private def static void createAllocTable() {
    val conn = getMainnetAllocDataConn
    try {
      conn.prepareStatement(
        "CREATE TABLE alloc (address BINARY(32) PRIMARY KEY, balance BINARY(32) NOT NULL)"
      ).execute
    } catch(Exception e) {
      LoggerController.logWarning(MainnetAllocData, "getMainnetAllocDataConn", "failed to create table")
    }
  }

  private def static void writeMainnetAllocData() {
    createAllocTable

    val conn = getMainnetAllocDataConn
    val tree = StaticEVMUtils.reverseRLP(mainnetAllocData)

    for (c : tree.children) {
      val _address = new ArrayList(c.children.get(0).data)
      while(_address.length < 20) {
        _address.add(0, new UnsignedByte(0))
      }
      val address = new EVMWord(_address, true)
      var EVMWord balance

      if(c.children.length == 2) {
        balance = new EVMWord(c.children.get(1).data, false)
      } else {
        balance = new EVMWord(0)
      }

      try {
        val query = String.format(
          "INSERT INTO alloc VALUES ('%s', '%s')",
          address.toHexString.substring(2),
          balance.toHexString.substring(2)
        )
        conn.prepareStatement(query).execute
      } catch(Exception e) {
        LoggerController.logWarning(MainnetAllocData, "getMainnetAllocDataConn", "entry probably exists already")
      }
    }

    conn.close
  }

  def static EVMWord getBalanceForAddress(EVMWord address) {
    if(mainnetAllocDataSize != ALLOC_SIZE) {
      writeMainnetAllocData
    }

    val query = String.format(
      "SELECT * FROM alloc WHERE address = '%s'",
      address.toHexString.substring(2)
    )
    val conn = mainnetAllocDataConn
    val result = conn.prepareStatement(query).executeQuery
    conn.close
    result.next
    new EVMWord(result.getBytes("balance"), true)
  }

  def static AllocDataIterator getMainnetAllocDataQueryIterator() {
    if(mainnetAllocDataSize != ALLOC_SIZE) {
      writeMainnetAllocData
    }

    val query = String.format(
      "SELECT * FROM alloc"
    )
    val conn = mainnetAllocDataConn
    val result = new AllocDataIterator(conn.prepareStatement(query).executeQuery)
    conn.close
    result
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
