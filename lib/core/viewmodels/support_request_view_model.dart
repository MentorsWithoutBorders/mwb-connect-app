import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/support_request_model.dart';

class SupportRequestViewModel extends ChangeNotifier {
  Api _api = locator<Api>();

  addSupportRequest(SupportRequest data) async {
    await _api.addDocument(path: 'support_requests', isForUser: false, data: data.toJson());
  }
}
