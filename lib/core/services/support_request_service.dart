import 'package:mwb_connect_app/core/models/support_request_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';

class SupportRequestService {
  final ApiService _api = locator<ApiService>();

  void addSupportRequest(SupportRequest supportRequest) {
    _api.postHTTP(url: '/support_requests', data: supportRequest.toJson());  
  }
}
