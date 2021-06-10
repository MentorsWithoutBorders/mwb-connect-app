import 'dart:async';
import 'package:mwb_connect_app/core/models/support_request_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class SupportRequestService {
  final ApiService _api = locator<ApiService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();

  void addSupportRequest(SupportRequest supportRequest) {
    String userId = _storageService.userId;
    _api.postHTTP(url: '/users/$userId/support_requests', data: supportRequest.toJson());  
  }
}
