import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

/// abstract class used to building your Custom AssetLoader
/// Example:
/// ```
///class FileAssetLoader extends AssetLoader {
///  @override
///  Future<Map<String, dynamic>> load(String path, Locale locale) async {
///    final file = File(path);
///    return json.decode(await file.readAsString());
///  }
///}
/// ```
abstract class AssetLoader {
  const AssetLoader();
  Future<Map<String, dynamic>> load(String path, Locale locale);
}

///
/// default used is RootBundleAssetLoader which uses flutter's assetloader
///
class RootBundleAssetLoader extends AssetLoader {
  const RootBundleAssetLoader();

  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${locale.toStringWithSeparator(separator: "-")}.json';
  }

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    EasyLocalization.logger.debug('Load asset from $path');
    final directory = await getApplicationDocumentsDirectory();
    if (localePath.contains(directory.path)) {
      return json.decode(await File(localePath).readAsString());
    } else {
      return json.decode(await rootBundle.loadString(localePath));
    }  
  }
}
