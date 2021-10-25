package com.mwbconnect.app
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import java.util.*


class MainActivity: FlutterActivity() {
  private val CHANNEL = "com.mwbconnect.app/api"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      // Note: this method is invoked on the main thread.
      call, result ->
      when (call.method) {
        "getHTTP" -> {
          getHTTP(call, result)
        }
        "postHTTP" -> {
          postHTTP(call, result)
        }
        "putHTTP" -> {
          putHTTP(call, result)
        }
        "deleteHTTP" -> {
          deleteHTTP(call, result)
        }
        else -> {
          result.notImplemented()
        }
      }
    }
  }

  fun getHTTP(call: MethodCall, result: MethodChannel.Result) {
    val url = call.argument<String>("url") as String
    val accessToken = call.argument<String>("accessToken") as String
    var responseMap: HashMap<String, String>
    GlobalScope.launch (Dispatchers.Main) {
      val apiService = ApiService()
      responseMap = apiService.getHTTP(url, accessToken)
      result.success(responseMap)
    }
  }

  fun postHTTP(call: MethodCall, result: MethodChannel.Result) {
    val url = call.argument<String>("url") as String
    val data = call.argument<String>("data") as HashMap<String, Any>
    val accessToken = call.argument<String>("accessToken") as String
    var responseMap: HashMap<String, String>
    GlobalScope.launch (Dispatchers.Main) {
      val apiService = ApiService()
      responseMap = apiService.postHTTP(url, data, accessToken)
      result.success(responseMap)
    }
  }

  fun putHTTP(call: MethodCall, result: MethodChannel.Result) {
    val url = call.argument<String>("url") as String
    val data = call.argument<String>("data") as HashMap<String, Any>
    val accessToken = call.argument<String>("accessToken") as String
    var responseMap: HashMap<String, String>
    GlobalScope.launch (Dispatchers.Main) {
      val apiService = ApiService()
      responseMap = apiService.putHTTP(url, data, accessToken)
      result.success(responseMap)
    }
  }

  fun deleteHTTP(call: MethodCall, result: MethodChannel.Result) {
    val url = call.argument<String>("url") as String
    val accessToken = call.argument<String>("accessToken") as String
    var responseMap: HashMap<String, String>
    GlobalScope.launch (Dispatchers.Main) {
      val apiService = ApiService()
      responseMap = apiService.deleteHTTP(url, accessToken)
      result.success(responseMap)
    }
  }
}
