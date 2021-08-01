import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/download_service.dart';

class RootViewModel extends ChangeNotifier {
  final UserService _userService = locator<UserService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final DownloadService _downloadService = locator<DownloadService>();
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

  void getImages() {
    _downloadService.getImages();    
  }

  String getUserId() {
    return _storageService.userId;
  }  
}
