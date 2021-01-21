import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  UserService _userService = locator<UserService>();

  Future<User> getUserDetails() async {
    return await _userService.getUserDetails();
  }

  setUserDetails(User user) async {
    _userService.setUserDetails(user);
  }  
}
