import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class RootViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();

  String? getUserId() {
    return _storageService.userId;
  }

  bool shouldLoadContent() {
    DateTime now = DateTime.now();
    DateTime lastLoadedContentDateTime = DateTime.now();
    if (_storageService.lastLoadedContentDateTime != null) {
      lastLoadedContentDateTime = DateTime.parse(_storageService.lastLoadedContentDateTime as String);
    }
    if (_storageService.lastLoadedContentDateTime == null || now.difference(lastLoadedContentDateTime).inSeconds >= 3) {
      return true;
    } else {
      return false;
    }
  }
  
  void setLastLoadedContentDateTime() {
    final DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
    final DateTime now = DateTime.now();
    _storageService.lastLoadedContentDateTime = dateFormat.format(now);       
  }
}
