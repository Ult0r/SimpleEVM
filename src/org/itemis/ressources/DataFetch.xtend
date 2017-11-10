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

import com.google.gson.JsonElement
import com.google.gson.JsonParser
import java.io.DataOutputStream
import javax.net.ssl.HttpsURLConnection
import java.io.InputStreamReader
import java.net.URL
import org.slf4j.LoggerFactory
import org.slf4j.Logger

class DataFetch {
  private final static Logger LOGGER = LoggerFactory.getLogger("Network")

  private static URL API_URL = new URL("https://mainnet.infura.io")
  private static int MAX_TRIES = 3

  def private JsonElement fetchData(String postData, boolean retryOnNull, int tries, int maxTries) {
    if(tries >= maxTries) {
      throw new UnsuccessfulDataFetchException("Wasn't able to retrieve data for " + postData + " after " + tries +
        "tries.")
    }

    var byte[] _postData = postData.bytes
    var int postDataLength = _postData.length

    var HttpsURLConnection conn = API_URL.openConnection() as HttpsURLConnection
    conn.setDoOutput(true)
    conn.setInstanceFollowRedirects(false)
    conn.setRequestMethod("POST")
    conn.setRequestProperty("Content-Type", "application/json")
    conn.setRequestProperty("charset", "utf-8")
    conn.setRequestProperty("Content-Length", Integer.toString(postDataLength))
    conn.setRequestProperty("Accept", "application/json")
    conn.setUseCaches(false)

    var DataOutputStream wr = new DataOutputStream(conn.getOutputStream())
    wr.write(_postData)

    if(conn.responseCode != 200) {
      val String errorMessage = String.format("returned %d, retrying...", conn.responseCode)
      LOGGER.warn(errorMessage)

      fetchData(postData, retryOnNull, tries + 1, maxTries)
    } else {
      val result = new JsonParser().parse(new InputStreamReader(conn.inputStream))
      if(result === null) {
        LOGGER.warn("returned null, retrying...")

        fetchData(postData, retryOnNull, tries + 1, maxTries)
      } else {
        LOGGER.info("result: " + result)

        try {
          if(result.asJsonObject.get("result").jsonNull && retryOnNull) {
            LOGGER.warn("result is null, retrying...")

            fetchData(postData, retryOnNull, tries + 1, maxTries)
          } else {
            result
          }
        } catch(Exception e) {
          LOGGER.warn("couldn't parse result")
          result
        }
      }
    }
  }

  def JsonElement fetchData(String postData, boolean retryOnNull, int maxTries) {
    LOGGER.info("postData: " + postData)
    fetchData(postData, true, 0, maxTries)
  }

  def JsonElement fetchData(String postData, boolean retryOnNull) {
    fetchData(postData, true, MAX_TRIES)
  }

  def JsonElement fetchData(String postData) {
    fetchData(postData, true)
  }
}
