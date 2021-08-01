import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/download_service.dart';
import 'package:mwb_connect_app/core/services/analytics_service.dart';

class RootViewModel extends ChangeNotifier {
  final UserService _userService = locator<UserService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final DownloadService _downloadService = locator<DownloadService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  bool isMentor;

  Future<void> getIsMentor() async {
    if (_storageService.userId != null && _storageService.isMentor == null) {
      User user = await _userService.getUserDetails();
      _userService.setUserStorage(user: user);
      isMentor = user.isMentor;
    } else {
      isMentor = _storageService.isMentor;
    }
  }
  
  void setPreferences() {
    _downloadService.downloadLocales().then((value) {
      _downloadService.setPreferences();
    });    
  }

  void getImages() {
    _downloadService.getImages();    
  }

  String getUserId() {
    return _storageService.userId;
  }  

  void sendAnalyticsEvent() {
    _analyticsService.sendEvent(
      eventName: 'root',
      properties: {
        'p1': 'property1',
        'p2': 'property2'
      }
    );
  }
}
