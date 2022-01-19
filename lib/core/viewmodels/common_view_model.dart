import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/timezone.dart';
import 'package:mwb_connect_app/core/models/timezone_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/push_notifications_service.dart';
import 'package:mwb_connect_app/core/services/navigation_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/download_service.dart';
import 'package:mwb_connect_app/core/services/app_flags_service.dart';
import 'package:mwb_connect_app/core/models/app_flags_model.dart';
import '../../service_locator.dart';

class CommonViewModel extends ChangeNotifier {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final DownloadService _downloadService = locator<DownloadService>();
  final AppFlagsService _appFlagsService = locator<AppFlagsService>();  
  double dialogInputHeight = 0.0;
  dynamic location;
  AppFlags appFlags = AppFlags(isTrainingEnabled: true, isMentoringEnabled: true);

  bool? getIsMentor() {
    return _storageService.isMentor;
  }  

  Future<void> initPushNotifications() async {
    final PushNotificationsService pushNotificationsService = locator<PushNotificationsService>();
    if (_storageService.isFCMPermissionRequested != true) {
      if (Platform.isIOS) {
        Future<void>.delayed(const Duration(milliseconds: 500), () async {
          await pushNotificationsService.init();
        });
      } else {
        await pushNotificationsService.init();
      }
    }
  }

  Future<void> setTimeZone() async {
    final UserService userService = locator<UserService>();
    final TimeZone timeZone = TimeZone();
    final String timeZoneName = await timeZone.getTimeZoneName();
    DateTime now = DateTime.now();
    String offset = now.timeZoneOffset.toString();
    List<String> offsetList = offset.split(':');
    offset = offsetList[0] + ':' + offsetList[1];
    TimeZoneModel timeZoneModel = TimeZoneModel(abbreviation: now.timeZoneName, name: timeZoneName, offset: offset);    
    userService.setUserTimeZone(timeZoneModel);
  } 

  Future<void> getAppFlags() async {
    appFlags = await _appFlagsService.getAppFlags();
  }     

  void setPreferences() {
    _downloadService.downloadLocales().then((value) {
      _downloadService.setPreferences();
    });    
  }     

  void setDialogInputHeight(double height) {
    dialogInputHeight = height;
    notifyListeners();
  }

  bool checkAppReload() {
    if (_storageService.shouldAppReload != null) {
      Phoenix.rebirth(NavigationService.instance.getCurrentContext() as BuildContext);
      _storageService.shouldAppReload = null;
      return true;
    } else {
      return false;
    }
  }  
}
