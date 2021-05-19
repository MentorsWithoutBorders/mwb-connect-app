import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info/package_info.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service_old.dart';
import 'package:mwb_connect_app/core/models/update_model.dart';
import 'package:mwb_connect_app/utils/update_status.dart';

class UpdatesViewModel extends ChangeNotifier {
  final Api _api = locator<Api>();

  Future<Update> _getCurrentVersion() async {
    final DocumentSnapshot doc = await _api.getDocumentById(path: 'updates', isForUser: false, id: 'version');
    if (doc.exists) {
      return Update.fromMap(doc.data(), doc.id);
    } else {
      return Update();
    }
  }
  
  Future<UpdateStatus> getUpdateStatus() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final Update update = await _getCurrentVersion();
    final List<String> packageVersion = packageInfo.version.split('.');
    final int packageVersionMajor = int.parse(packageVersion[0]);
    final int packageVersionMinor = int.parse(packageVersion[1]);
    final int packageVersionRelease = int.parse(packageVersion[2]);
    final int packageVersionBuild = int.parse(packageInfo.buildNumber);
    if (update.major > packageVersionMajor ||
        update.minor > packageVersionMinor &&
        update.major >= packageVersionMajor) {
      return UpdateStatus.FORCE_UPDATE;
    } else if (update.release > packageVersionRelease &&
        update.minor >= packageVersionMinor &&
        update.major >= packageVersionMajor ||
        update.build > packageVersionBuild &&
        update.release >= packageVersionRelease &&
        update.minor >= packageVersionMinor &&
        update.major >= packageVersionMajor) {
      return UpdateStatus.RECOMMEND_UPDATE;
    } else {
      return UpdateStatus.NO_UPDATE;
    }
  }

}
