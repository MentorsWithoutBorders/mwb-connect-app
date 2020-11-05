import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/feedback_model.dart';

class FeedbackViewModel extends ChangeNotifier {
  Api _api = locator<Api>();

  addFeedback(FeedbackModel data) async {
    await _api.addDocument(path: 'feedback', isForUser: false, data: data.toJson());
  }
}
