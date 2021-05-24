import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/authentication_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/tokens_model.dart';

class LoginSignupViewModel extends ChangeNotifier {
  final AuthService _authService = locator<AuthService>();

  Future<String> signUp(User user) async {
    // final ApprovedUser approvedUser = await _userService.checkApprovedUser(_email);
    // if (approvedUser != null) {
      Uuid uuid = Uuid();
      user.id = uuid.v4();
      try {
        return await _authService.signUp(user);
      } catch(error) {
        throw(error);
      }
    // } else {
    //   throw Exception('sign_up.not_approved'.tr());
    // }    
  }

  Future<String> login(User user) async {
    try {
      return await _authService.login(user);
    } catch(error) {
      throw(error);
    }
  }  
}
