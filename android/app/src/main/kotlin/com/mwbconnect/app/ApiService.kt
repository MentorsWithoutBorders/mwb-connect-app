package com.mwbconnect.app
import org.json.JSONObject
import com.github.kittinunf.fuel.Fuel
import kotlinx.coroutines.*
import java.util.*
import com.github.kittinunf.result.Result
import com.google.gson.Gson

class ApiService {
  suspend fun getHTTP(url: String, data: HashMap<String, Any>, accessToken: String): HashMap<String, String> {
    val fuelUrl = url
    val fuelData = data
    val fuelAccessToken = accessToken
    val gson = Gson()
    var responseMap: HashMap<String, String> = hashMapOf()
    return withContext(Dispatchers.IO) {
      val (request, response, result) = Fuel.get(fuelUrl)
        .body(JSONObject(gson.toJson(fuelData)).toString())
        .header("Content-Type", "application/json; charset=UTF-8")
        .header("Accept", "application/json")
        .header("Authorization", fuelAccessToken)
        .responseString()

      when (result) {
        is Result.Failure -> {
          responseMap.put("statusCode", response.statusCode.toString())
          responseMap.put("data", String(response.data))
          return@withContext responseMap
        }
        is Result.Success -> {
          val data = result.get()
          responseMap.put("statusCode", response.statusCode.toString())
          responseMap.put("data", data)
          return@withContext responseMap
        }
      }
    }
  }

  suspend fun postHTTP(url: String, data: HashMap<String, Any>, accessToken: String): HashMap<String, String> {
    val fuelUrl = url
    val fuelData = data
    val fuelAccessToken = accessToken
    val gson = Gson()
    var responseMap: HashMap<String, String> = hashMapOf()
    return withContext(Dispatchers.IO) {
      val (request, response, result) = Fuel.post(fuelUrl)
        .body(JSONObject(gson.toJson(fuelData)).toString())
        .header("Content-Type", "application/json; charset=UTF-8")
        .header("Accept", "application/json")
        .header("Authorization", fuelAccessToken)
        .responseString()

      when (result) {
        is Result.Failure -> {
          responseMap.put("statusCode", response.statusCode.toString())
          responseMap.put("data", String(response.data))
          return@withContext responseMap
        }
        is Result.Success -> {
          val data = result.get()
          responseMap.put("statusCode", response.statusCode.toString())
          responseMap.put("data", data)
          return@withContext responseMap
        }
      }
    }
  }

  suspend fun putHTTP(url: String, data: HashMap<String, Any>, accessToken: String): HashMap<String, String> {
    val fuelUrl = url
    val fuelData = data
    val fuelAccessToken = accessToken
    val gson = Gson()
    var responseMap: HashMap<String, String> = hashMapOf()
    return withContext(Dispatchers.IO) {
      val (request, response, result) = Fuel.put(fuelUrl)
        .body(JSONObject(gson.toJson(fuelData)).toString())
        .header("Content-Type", "application/json; charset=UTF-8")
        .header("Accept", "application/json")
        .header("Authorization", fuelAccessToken)
        .responseString()

      when (result) {
        is Result.Failure -> {
          responseMap.put("statusCode", response.statusCode.toString())
          responseMap.put("data", String(response.data))
          return@withContext responseMap
        }
        is Result.Success -> {
          val data = result.get()
          responseMap.put("statusCode", response.statusCode.toString())
          responseMap.put("data", data)
          return@withContext responseMap
        }
      }
    }
  }

  suspend fun deleteHTTP(url: String, accessToken: String): HashMap<String, String> {
    val fuelUrl = url
    val fuelAccessToken = accessToken
    var responseMap: HashMap<String, String> = hashMapOf()
    return withContext(Dispatchers.IO) {
      val (request, response, result) = Fuel.delete(fuelUrl)
        .header("Content-Type", "application/json; charset=UTF-8")
        .header("Accept", "application/json")
        .header("Authorization", fuelAccessToken)
        .responseString()

      when (result) {
        is Result.Failure -> {
          responseMap.put("statusCode", response.statusCode.toString())
          responseMap.put("data", String(response.data))
          return@withContext responseMap
        }
        is Result.Success -> {
          val data = result.get()
          responseMap.put("statusCode", response.statusCode.toString())
          responseMap.put("data", data)
          return@withContext responseMap
        }
      }
    }
  }
}