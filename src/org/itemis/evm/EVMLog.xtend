package org.itemis.evm

import org.eclipse.xtend.lib.annotations.Accessors
import org.itemis.types.EVMWord
import java.util.List

final class EVMLog {
  @Accessors private final EVMWord address
  @Accessors private final int topicCount
  @Accessors private final List<EVMWord> topics = newArrayList
  @Accessors private final byte[] data
  
  private new(EVMWord address, int topicCount, byte[] data) {
    this.address = address
    this.topicCount = topicCount
    this.data = data
  }
  
  new(EVMWord address, byte[] data) {
    this(address, 0, data)
  }
  
  new(EVMWord address, EVMWord topic0, byte[] data) {
    this(address, 1, data)
    this.topics.add(topic0)   
  }
  
  new(EVMWord address, EVMWord topic0, EVMWord topic1, byte[] data) {
    this(address, 2, data)
    this.topics.add(topic0)   
    this.topics.add(topic1)
  }
  
  new(EVMWord address, EVMWord topic0, EVMWord topic1, EVMWord topic2, byte[] data) {
    this(address, 3, data)
    this.topics.add(topic0)   
    this.topics.add(topic1)
    this.topics.add(topic2)
  }
  
  new(EVMWord address, EVMWord topic0, EVMWord topic1, EVMWord topic2, EVMWord topic3, byte[] data) {
    this(address, 4, data)
    this.topics.add(topic0)   
    this.topics.add(topic1)
    this.topics.add(topic2)
    this.topics.add(topic3)
  }
}