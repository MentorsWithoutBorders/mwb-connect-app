import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/profile_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';

class ProfileViewModel extends ChangeNotifier {
  UserService _userService = locator<UserService>();
  ProfileService _profileService = locator<ProfileService>();

  Future<User> getUserDetails() async {
    return await _userService.getUserDetails();
  }

  setUserDetails(User user) async {
    _userService.setUserDetails(user);
  }
  
  Future<List<Field>> getFields() async {
    return await _profileService.getFields();
  }  
}
