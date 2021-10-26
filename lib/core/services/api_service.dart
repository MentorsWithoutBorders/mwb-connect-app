import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/core/services/navigation_service.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/tokens_model.dart';
import 'package:mwb_connect_app/core/models/error_model.dart';

class ApiService {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final String baseUrl = 'https://mwbtraining.co/staging/api/v1';
  static const platform = MethodChannel('com.mwbconnect.app/api');
  bool refreshingToken = false;
  
  Map<String, String> getHeaders() {
    String? accessToken = _storageService.accessToken;
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': '$accessToken',
    };
    return headers;    
  }

  Future<dynamic> getHTTP({required String url}) async {    
    String finalUrl = baseUrl + url;
    dynamic responseBody;
    int statusCode = 0;
    if (Platform.isAndroid) {
      String accessToken = _storageService.accessToken ?? '';
      final response = await platform.invokeMethod('getHTTP', {'url': finalUrl, 'accessToken': accessToken});
      final responseMap = response as Map<Object?, Object?>;
      if (responseMap['statusCode'] != null && responseMap['data'] != null) {
        statusCode = int.parse(responseMap['statusCode'] as String);
        final responseData = responseMap['data'] as String;
        try {
          responseBody = jsonDecode(responseData);
        } catch (e) {}
      }
    } else {
      final response = await http.get(
        Uri.parse(finalUrl), 
        headers: getHeaders(),
      );
      statusCode = response.statusCode;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {}
    }
    switch (statusCode) {
      case 200:
        return responseBody;
      case 400: 
        throw(ErrorModel(message: _getError(responseBody)));
      case 401: 
        throw(ErrorModel(message: _getError(responseBody)));
        // if (!refreshingToken) {
        //   await _refreshToken();      
        // }
        // if (_storageService.refreshToken != null) {      
        //   return await postHTTP(url: url);
        // }                
    }    
    return responseBody; 
  }

  Future<dynamic> postHTTP({required String url, Map<String, Object?>? data}) async { 
    String finalUrl = baseUrl + url;
    dynamic responseBody;
    int statusCode = 0;
    if (Platform.isAndroid) {
      String accessToken = _storageService.accessToken ?? '';
      final response = await platform.invokeMethod('postHTTP', {'url': finalUrl, 'data': data, 'accessToken': accessToken});
      final responseMap = response as Map<Object?, Object?>;
      if (responseMap['statusCode'] != null && responseMap['data'] != null) {
        statusCode = int.parse(responseMap['statusCode'] as String);
        final responseData = responseMap['data'] as String;
        try {
          responseBody = jsonDecode(responseData);
        } catch (e) {}
      }
    } else {
      final response = await http.post(
        Uri.parse(finalUrl), 
        headers: getHeaders(),
        body: json.encode(data)
      );
      statusCode = response.statusCode;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {}
    }
    switch (statusCode) {
      case 200:
        return responseBody;
      case 400: 
        throw(ErrorModel(message: _getError(responseBody)));
      case 401: 
        throw(ErrorModel(message: _getError(responseBody)));
        // if (!refreshingToken) {
        //   await _refreshToken();      
        // }
        // if (_storageService.refreshToken != null) {      
        //   return await postHTTP(url: url, data: data);
        // }                
    }      
    return responseBody;
  }

  Future<dynamic> putHTTP({required String url, Map<String, Object?>? data}) async {
   String finalUrl = baseUrl + url;
    dynamic responseBody;
    int statusCode = 0;
    if (Platform.isAndroid) {
      String accessToken = _storageService.accessToken ?? '';
      final response = await platform.invokeMethod('putHTTP', {'url': finalUrl, 'data': data, 'accessToken': accessToken});
      final responseMap = response as Map<Object?, Object?>;
      if (responseMap['statusCode'] != null && responseMap['data'] != null) {
        statusCode = int.parse(responseMap['statusCode'] as String);
        final responseData = responseMap['data'] as String;
        try {
          responseBody = jsonDecode(responseData);
        } catch (e) {}
      }
    } else {
      final response = await http.put(
        Uri.parse(finalUrl), 
        headers: getHeaders(),
        body: json.encode(data)
      );
      statusCode = response.statusCode;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {}
    }
    switch (statusCode) {
      case 200:
        return responseBody;
      case 400: 
        throw(ErrorModel(message: _getError(responseBody)));
      case 401: 
        throw(ErrorModel(message: _getError(responseBody)));
        // if (!refreshingToken) {
        //   await _refreshToken();      
        // }
        // if (_storageService.refreshToken != null) {      
        //   return await postHTTP(url: url, data: data);
        // }                
    }        
    return responseBody;
  }
  
  Future<dynamic> deleteHTTP({required String url}) async {
    String finalUrl = baseUrl + url;
    dynamic responseBody;
    int statusCode = 0;
    if (Platform.isAndroid) {
      String accessToken = _storageService.accessToken ?? '';
      final response = await platform.invokeMethod('deleteHTTP', {'url': finalUrl, 'accessToken': accessToken});
      final responseMap = response as Map<Object?, Object?>;
      if (responseMap['statusCode'] != null && responseMap['data'] != null) {
        statusCode = int.parse(responseMap['statusCode'] as String);
        final responseData = responseMap['data'] as String;
        try {
          responseBody = jsonDecode(responseData);
        } catch (e) {}
      }
    } else {
      final response = await http.delete(
        Uri.parse(finalUrl), 
        headers: getHeaders()
      );
      statusCode = response.statusCode;
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {}
    }
    switch (statusCode) {
      case 200:
        return responseBody;
      case 400: 
        throw(ErrorModel(message: _getError(responseBody)));
      case 401: 
        throw(ErrorModel(message: _getError(responseBody)));
        // if (!refreshingToken) {
        //   await _refreshToken();      
        // }
        // if (_storageService.refreshToken != null) {      
        //   return await postHTTP(url: url, data: data);
        // }                
    }      
    return responseBody;
  }

  String? _getError(dynamic responseBody) {
    ErrorModel error = ErrorModel.fromJson(responseBody);
    return error.message;
  }  

  Future<void> _refreshToken() async {
    String? userId = _storageService.userId;
    String? refreshToken = _storageService.refreshToken;
    refreshingToken = true;
    final response = await http.get(
      Uri.parse(baseUrl + '/users/$userId/access_token?refreshToken=$refreshToken'),
      headers: getHeaders()
    );
    refreshingToken = false;
    var json = jsonDecode(response.body);    
    Tokens tokens = Tokens.fromJson(json);
    _storageService.accessToken = tokens.accessToken;
    _storageService.refreshToken = tokens.refreshToken;
    if (_storageService.refreshToken == null) {
      _logout();
    }    
  }
  
  Future<void> _logout() async {
    resetStorage();
    NavigationService.instance.navigateTo('root');
  }

  void resetStorage() {
    _storageService.accessToken = null;
    _storageService.userId = null;
    _storageService.userEmail = null;
    _storageService.userName = '';
    _storageService.isMentor = null;
    _storageService.shouldAppReload = null;
    _storageService.lastUpdateShownDateTime = null;
    _storageService.lastPNShownDateTime = null;
    _storageService.isFCMPermissionRequested = null;
  }    
}