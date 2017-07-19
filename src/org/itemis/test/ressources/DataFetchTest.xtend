package org.itemis.test.ressources

import org.junit.Test
import java.net.URL
import javax.net.ssl.HttpsURLConnection
import java.io.DataOutputStream
import com.google.gson.JsonParser
import java.io.InputStreamReader
import com.google.gson.JsonElement
import org.junit.Assert

class DataFetchTest {
  
  private static URL API_URL = new URL("https://mainnet.infura.io")
  private static String test = '{"jsonrpc": "2.0", "id": 1, "method": "eth_getBlockByNumber", "params": ["0x0", true]}'

  @Test
  def void testDataFetch() {
    var byte[] postData = test.bytes
    var int postDataLength = postData.length
    
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
    wr.write(postData)
    
    Assert.assertEquals(conn.responseCode, 200)
    Assert.assertEquals(conn.responseMessage, "OK")
    
    var JsonElement response = new JsonParser().parse(new InputStreamReader(conn.inputStream))
    var difficulty = response.getAsJsonObject.get("result").getAsJsonObject.get("difficulty").asString
    
    Assert.assertEquals(difficulty, "0x400000000")
  }
}
