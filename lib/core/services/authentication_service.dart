import 'dart:async';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/error_model.dart';
import 'package:mwb_connect_app/core/services/navigation_service.dart';
import 'package:mwb_connect_app/core/services/push_notifications_service.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/tokens_model.dart';

class AuthService {
  final ApiService _api = locator<ApiService>();
  final UserService _userService = locator<UserService>();    
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final PushNotificationsService pushNotificationsService = locator<PushNotificationsService>();

  Future<String> signUp(User user) async {
    dynamic response;
    try {    
      response = await _api.postHTTP(url: '/signup', data: user.toJson());
    } catch(error) {
      throw(error);
    }      
    Tokens tokens = Tokens.fromJson(response);
    user.id = tokens.userId;
    _setTokens(tokens);
    await _setUserStorage(user);
    return tokens.userId!;
  }

  Future<String> login(User user) async {
    dynamic response;
    try {
      response = await _api.postHTTP(url: '/login', data: user.toJson());
    } on ErrorModel catch(error) {
      throw(error);
    }
    Tokens tokens = Tokens.fromJson(response);
    user.id = tokens.userId;
    _setTokens(tokens);
    await _setUserStorage(user);
    return tokens.userId!;    
  }
  
  Future<void> _setUserStorage(User user) async {
    await _userService.setUserStorage(user: user);
  }  

  void _setTokens(Tokens tokens) {
    _storageService.accessToken = tokens.accessToken;
    _storageService.refreshToken = tokens.refreshToken;    
  }

  void logout() {
    _api.postHTTP(url: '/logout');
    _api.resetStorage();
    pushNotificationsService.deleteFCMToken();
    NavigationService.instance.navigateTo('root');
  }
} 
