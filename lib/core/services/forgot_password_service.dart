import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';

class ForgotPasswordService {
  final ApiService _api = locator<ApiService>();

  Future<void> sendResetPassword(String email) async {
    await _api.postHTTP(url: '/send_reset_password/$email');  
  }
}
