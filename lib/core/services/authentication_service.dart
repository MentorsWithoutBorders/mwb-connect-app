import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/tokens_model.dart';
import 'package:mwb_connect_app/utils/constants.dart';

class AuthService {
  final ApiService _api = locator<ApiService>();
  final UserService _userService = locator<UserService>();    
  final LocalStorageService _storageService = locator<LocalStorageService>();

  Future<String> signUp(User user) async {
    http.Response response = await _api.postHTTP(url: '/signup', data: user.toJson());
    var json = jsonDecode(response.body);
    Tokens tokens = Tokens.fromJson(json);
    user.id = tokens.userId;
    _setUserStorage(user);
    _setTokens(tokens);
    return tokens.userId;
  }

  Future<String> login(User user) async {
    http.Response response = await _api.postHTTP(url: '/login', data: user.toJson());
    var json = jsonDecode(response.body);
    Tokens tokens = Tokens.fromJson(json);
    user.id = tokens.userId;
    _setUserStorage(user);
    _setTokens(tokens);
    return tokens.userId;
  }
  
  Future<void> _setUserStorage(User user) async {
    await _userService.setUserStorage(user: user);
  }  

  void _setTokens(Tokens tokens) {
    _storageService.accessToken = tokens.accessToken;
    _storageService.refreshToken = tokens.refreshToken;    
  }

  Future<void> logout() async {
    User user = User(id: _storageService.userId);
    _api.resetStorage();
    await _api.postHTTP(url: '/logout', data: user.toJson());
  }
} 
