import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/in_app_message_model.dart';
import 'package:mwb_connect_app/core/services/in_app_messages_service.dart';

class InAppMessagesViewModel extends ChangeNotifier {
  final InAppMessagesService _inAppMessagesService = locator<InAppMessagesService>();
  InAppMessage? inAppMessage;

  Future<void> getInAppMessage() async {
    inAppMessage = await _inAppMessagesService.getInAppMessage();
  }  

  Future<void> deleteInAppMessage() async {
    inAppMessage = null;
    await _inAppMessagesService.deleteInAppMessage();
    return ;
  }

}
