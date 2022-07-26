import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/in_app_message_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';

class InAppMessagesService {
  final ApiService _api = locator<ApiService>();

  Future<InAppMessage> getInAppMessage() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/in_app_messages');
    return InAppMessage.fromJson(response);
  }

  Future<void> deleteInAppMessage() async {
    await _api.deleteHTTP(url: '/in_app_messages');
    return ;
  }   
}