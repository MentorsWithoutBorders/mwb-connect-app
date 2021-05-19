import 'dart:async';
import 'package:dio/dio.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/tokens_model.dart';
import 'package:mwb_connect_app/utils/constants.dart';

class AuthService {
  final ApiService _api = locator<ApiService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();

  Future<String> signUp(User user) async {
    Response response = await _api.postHTTP('/signup', user.toJson());
    Tokens tokens = Tokens.fromJson(response.data);
    user.id = tokens.userId;
    _setUserStorage(user);
    _setTokens(tokens);
    return tokens.userId;
  }

  Future<String> login(User user) async {
    Response response = await _api.postHTTP('/login', user.toJson());
    Tokens tokens = Tokens.fromJson(response.data);
    user.id = tokens.userId;
    _setUserStorage(user);
    _setTokens(tokens);
    return tokens.userId;
  }
  
  Future<void> _setUserStorage(User user) async {
    final UserService _userService = locator<UserService>();  
    await _userService.setUserStorage(user: user);
  }  

  void _setTokens(Tokens tokens) {
    _storageService.accessToken = tokens.accessToken;
    _storageService.refreshToken = tokens.refreshToken;    
  }

  Future<void> logout() async {
    User user = User(id: _storageService.userId);
    await _api.postHTTP('/logout', user.toJson());
    _resetStorage();
  }

  void _resetStorage() {
    _storageService.userId = null;
    _storageService.quizNumber = 1;
    _storageService.notificationsEnabled = AppConstants.notificationsEnabled;
    _storageService.notificationsTime = AppConstants.notificationsTime;       
  }
} 
