import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/tokens_model.dart';
import 'package:mwb_connect_app/core/models/error_model.dart';

class ApiService {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final String baseUrl = 'http://143.198.173.157:3000/api/v1';
  bool refreshingToken = false;
  
  Map<String, String> getHeaders() {
    String accessToken = _storageService.accessToken;
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': '$accessToken',
    };
    return headers;    
  }

  Future<http.Response> getHTTP({String url}) async {
    final response = await http.get(
      Uri.parse(baseUrl + url), 
      headers: getHeaders()
    );
    if (_storageService.refreshToken == null) {
      _logout();
    } else if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 400) {
      throw(Exception(_getError(response)));
    } else if (response.statusCode == 401) {
      if (!refreshingToken) {
        await _refreshToken();
      }
      return getHTTP(url: url);
    }
  }

  Future<http.Response> postHTTP({String url, dynamic data}) async {
    final response = await http.post(
      Uri.parse(baseUrl + url), 
      headers: getHeaders(),
      body: json.encode(data)
    );
    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 400) {
      throw(Exception(_getError(response)));
    } else if (response.statusCode == 401) {
      if (!refreshingToken) {
        await _refreshToken();
      }
      return await postHTTP(url: url, data: data);
    }   
  }

  Future<http.Response> putHTTP({String url, dynamic data}) async {
    final response = await http.put(
      Uri.parse(baseUrl + url), 
      headers: getHeaders(),
      body: json.encode(data)
    );
    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 400) {
      throw(Exception(_getError(response)));
    } else if (response.statusCode == 401) {
      if (!refreshingToken) {
        await _refreshToken();
      }
      return await putHTTP(url: url, data: data);
    }  
  }
  
  Future<http.Response> deleteHTTP({String url}) async {
    final response = await http.delete(
      Uri.parse(baseUrl + url), 
      headers: getHeaders()
    );
    if (response.statusCode == 200) {
      return response;
    } else if (response.statusCode == 400) {
      throw(Exception(_getError(response)));
    } else if (response.statusCode == 401) {
      if (!refreshingToken) {
        await _refreshToken();
      }
      return await deleteHTTP(url: url);
    }
  }

  String _getError(http.Response response) {
    var json = jsonDecode(response.body);
    ErrorModel error = ErrorModel.fromJson(json);
    return error.message;
  }  

  Future<void> _refreshToken() async {
    String userId = _storageService.userId;
    String refreshToken = _storageService.refreshToken;
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
  }
  
  Future<void> _logout() async {
    resetStorage();
    await postHTTP(url: '/logout', data: {});
  }

  void resetStorage() {
    _storageService.userId = null;
    _storageService.userEmail = null;
    _storageService.userName = '';
    _storageService.isMentor = null;
    _storageService.quizNumber = null;
    _storageService.isLastStepAdded = null;
    _storageService.notificationsEnabled = AppConstants.notificationsEnabled;
    _storageService.notificationsTime = AppConstants.notificationsTime;
  }    
}