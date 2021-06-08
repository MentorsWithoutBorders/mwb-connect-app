import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/support_request_model.dart';

class SupportRequestViewModel extends ChangeNotifier {
  final ApiService _api = locator<ApiService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();   

  Future<void> addSupportRequest(SupportRequest quiz) async {
    String userId = _storageService.userId;
    await _api.postHTTP(url: '/$userId/support_requests', data: quiz.toJson());  
  }
}
