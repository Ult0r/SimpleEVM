package org.itemis.ressources

import com.google.gson.JsonElement
import com.google.gson.JsonParser
import java.io.DataOutputStream
import javax.net.ssl.HttpsURLConnection
import java.io.InputStreamReader
import java.net.URL

class DataFetch {
  private static URL API_URL = new URL("https://mainnet.infura.io")
  
  def JsonElement fetchData(String postData) {
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
    
    new JsonParser().parse(new InputStreamReader(conn.inputStream))
  }  
}