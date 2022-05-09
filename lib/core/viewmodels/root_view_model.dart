import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';

class RootViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final ApiService _api = locator<ApiService>();  
  final UserService _userService = locator<UserService>();
  bool? isMentor;

  Future<void> getUserDetails() async {
    if (_storageService.accessToken != null) {
      User user = await _userService.getUserDetails();
      _userService.setUserStorage(user: user);
      isMentor = user.isMentor;
    } else {
      _api.resetStorage();
    }
  }

  String? getUserId() {
    return _storageService.userId;
  }  
}
