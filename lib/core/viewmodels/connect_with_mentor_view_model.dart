import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/profile_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';

class ConnectWithMentorViewModel extends ChangeNotifier {
  final UserService _userService = locator<UserService>();
  final ProfileService _profileService = locator<ProfileService>();

  Future<User> getUserDetails() async {
    return _userService.getUserDetails();
  }

}
