import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/update_model.dart';
import 'package:mwb_connect_app/utils/update_status.dart';

class UpdatesViewModel extends ChangeNotifier {
  final ApiService _api = locator<ApiService>();

  Future<Update> _getCurrentVersion() async {
    http.Response response = await _api.getHTTP(url: '/updates');
    Update update;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      update = Update.fromJson(json);
    }
    return update;
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
