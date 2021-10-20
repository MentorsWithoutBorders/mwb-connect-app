import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/core/services/navigation_service.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/tokens_model.dart';
import 'package:mwb_connect_app/core/models/error_model.dart';

class ApiService {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final String baseUrl = 'https://mwbtraining.co/staging/api/v1';
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

  Future<http.Response> getHTTP({required String url}) async {
    final response = await http.get(
      Uri.parse(baseUrl + url), 
      headers: getHeaders()
    );
    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 400) {
      throw(ErrorModel(message: _getError(response)));
    } else if (response.statusCode == 401) {
      throw(ErrorModel(message: _getError(response)));
      // if (!refreshingToken) {
      //   await _refreshToken();
      // }
      // if (_storageService.refreshToken != null) {
      //   return getHTTP(url: url);
      // }      
    }
    return response;
  }

  Future<http.Response> postHTTP({required String url, dynamic data}) async {
    final response = await http.post(
      Uri.parse(baseUrl + url), 
      headers: getHeaders(),
      body: json.encode(data)
    );
    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 400) {
      throw(ErrorModel(message: _getError(response)));
    } else if (response.statusCode == 401) {
      throw(ErrorModel(message: _getError(response)));
      // if (!refreshingToken) {
      //   await _refreshToken();      
      // }
      // if (_storageService.refreshToken != null) {      
      //   return await postHTTP(url: url, data: data);
      // }
    }
    return response;
  }

  Future<http.Response> putHTTP({required String url, dynamic data}) async {
    final response = await http.put(
      Uri.parse(baseUrl + url), 
      headers: getHeaders(),
      body: json.encode(data)
    );
    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 400) {
      throw(ErrorModel(message: _getError(response)));
    } else if (response.statusCode == 401) {
      throw(ErrorModel(message: _getError(response)));
      // if (!refreshingToken) {
      //   await _refreshToken();       
      // }
      // if (_storageService.refreshToken != null) {
      //   return await putHTTP(url: url, data: data);
      // }
    }
    return response;
  }
  
  Future<http.Response> deleteHTTP({required String url}) async {
    final response = await http.delete(
      Uri.parse(baseUrl + url), 
      headers: getHeaders()
    );
    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 400) {
      throw(ErrorModel(message: _getError(response)));
    } else if (response.statusCode == 401) {
      throw(ErrorModel(message: _getError(response)));
      // if (!refreshingToken) {
      //   await _refreshToken();    
      // }
      // if (_storageService.refreshToken != null) {      
      //   return await deleteHTTP(url: url);
      // }
    }
    return response;
  }

  String? _getError(http.Response response) {
    var json = jsonDecode(response.body);
    ErrorModel error = ErrorModel.fromJson(json);
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
    _storageService.quizNumber = null;
    _storageService.lastStepAddedId = null;
    _storageService.shouldAppReload = null;
    _storageService.lastUpdateShownDateTime = null;
    _storageService.lastPNShownDateTime = null;
    _storageService.isFCMPermissionRequested = null;
  }    
}