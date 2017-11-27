/*******************************************************************************
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 * Lars Reimers for itemis AG
 *******************************************************************************/
package org.itemis.evm

import org.eclipse.xtend.lib.annotations.Accessors
import org.itemis.types.impl.EVMWord
import java.util.List
import org.itemis.types.impl.Address
import org.itemis.types.impl.Bloom2048

final class EVMLog {
  @Accessors private final Address address
  @Accessors private final int topicCount
  @Accessors private final List<EVMWord> topics = newArrayList
  @Accessors private final byte[] data

  private new(Address address, int topicCount, byte[] data) {
    this.address = address
    this.topicCount = topicCount
    this.data = data
  }

  new(Address address, byte[] data) {
    this(address, 0, data)
  }

  new(Address address, EVMWord topic0, byte[] data) {
    this(address, 1, data)
    this.topics.add(topic0)
  }

  new(Address address, EVMWord topic0, EVMWord topic1, byte[] data) {
    this(address, 2, data)
    this.topics.add(topic0)
    this.topics.add(topic1)
  }

  new(Address address, EVMWord topic0, EVMWord topic1, EVMWord topic2, byte[] data) {
    this(address, 3, data)
    this.topics.add(topic0)
    this.topics.add(topic1)
    this.topics.add(topic2)
  }

  new(Address address, EVMWord topic0, EVMWord topic1, EVMWord topic2, EVMWord topic3, byte[] data) {
    this(address, 4, data)
    this.topics.add(topic0)
    this.topics.add(topic1)
    this.topics.add(topic2)
    this.topics.add(topic3)
  }
  
  
  def public Bloom2048 addToBloom(Bloom2048 bloom) {
    var result = bloom
    result = result.addToBloom(address.toByteArray)
    for (topic: topics) {
      result = result.addToBloom(topic.toByteArray)
    }
    result
  }
}
