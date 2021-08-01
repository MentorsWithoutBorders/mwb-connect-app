import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/navigation_service.dart';
import 'package:mwb_connect_app/core/services/download_service.dart';

import '../../service_locator.dart';

class CommonViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final DownloadService _downloadService = locator<DownloadService>();  
  double dialogInputHeight = 0.0;
  dynamic location;

  void setDialogInputHeight(double height) {
    dialogInputHeight = height;
    notifyListeners();
  }

  void setPreferences() {
    _downloadService.downloadLocales().then((value) {
      _downloadService.setPreferences();
    });    
  }  

  bool checkAppReload() {
    if (_storageService.shouldAppReload != null) {
      Phoenix.rebirth(NavigationService.instance.getCurrentContext());
      _storageService.shouldAppReload = null;
      return true;
    } else {
      return false;
    }
  }   
}
