import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/forgot_password_service.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final ForgotPasswordService _forgotPasswordService = locator<ForgotPasswordService>();

  Future<void> sendResetPassword(String email) async {
    await _forgotPasswordService.sendResetPassword(email);
  }
}
