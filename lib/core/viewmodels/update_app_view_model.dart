import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/update_status.dart';
import 'package:mwb_connect_app/core/models/app_version_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/update_app_service.dart';

class UpdateAppViewModel extends ChangeNotifier {
  final UpdateAppService _updateAppService = locator<UpdateAppService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();
  
  Future<UpdateStatus> getUpdateStatus() async {
    final AppVersion appVersion = await _updateAppService.getCurrentVersion();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final List<String> packageVersion = packageInfo.version.split('.');
    final int packageVersionMajor = int.parse(packageVersion[0]);
    final int packageVersionMinor = int.parse(packageVersion[1]);
    final int packageVersionRevision = int.parse(packageVersion[2]);
    final int packageVersionBuild = int.parse(packageInfo.buildNumber);
    AppVersion currentAppVersion = AppVersion(
      major: packageVersionMajor,
      minor: packageVersionMinor,
      revision: packageVersionRevision,
      build: packageVersionBuild
    );    
    _updateAppService.sendAppVersion(currentAppVersion);
    final DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat);
    final DateTime now = DateTime.now();
    if (!_shouldShowUpdate()) {
      return UpdateStatus.NO_UPDATE;
    } else {
      if (appVersion.major as int > packageVersionMajor ||
          appVersion.minor as int > packageVersionMinor &&
          appVersion.major as int >= packageVersionMajor) {
        _storageService.lastUpdateShownDateTime = dateFormat.format(now);
        return UpdateStatus.FORCE_UPDATE;
      } else if (appVersion.revision as int > packageVersionRevision &&
          appVersion.minor as int >= packageVersionMinor &&
          appVersion.major as int >= packageVersionMajor ||
          appVersion.build as int > packageVersionBuild &&
          appVersion.revision as int >= packageVersionRevision &&
          appVersion.minor as int >= packageVersionMinor &&
          appVersion.major as int >= packageVersionMajor) {
        _storageService.lastUpdateShownDateTime = dateFormat.format(now);            
        return UpdateStatus.RECOMMEND_UPDATE;
      } else {
        return UpdateStatus.NO_UPDATE;
      }
    }
  }

  bool _shouldShowUpdate() {
    final DateTime now = DateTime.now();
    DateTime lastUpdateShownDateTime = DateTime.now();
    if (_storageService.lastUpdateShownDateTime != null) {
      lastUpdateShownDateTime = DateTime.parse(_storageService.lastUpdateShownDateTime as String);
    }
    if (_storageService.lastUpdateShownDateTime == null || now.difference(lastUpdateShownDateTime).inDays >= 7) {
      return true;
    } else {
      return false;
    }       
  }
}
