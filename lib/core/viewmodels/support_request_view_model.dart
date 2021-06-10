import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/support_request_service.dart';
import 'package:mwb_connect_app/core/models/support_request_model.dart';

class SupportRequestViewModel extends ChangeNotifier {
  final SupportRequestService _supportRequestService = locator<SupportRequestService>();

  void addSupportRequest(SupportRequest supportRequest) {
    _supportRequestService.addSupportRequest(supportRequest);
  }
}
