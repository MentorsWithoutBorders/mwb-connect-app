import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'json_asset_loader.dart';

class WidgetLoader {
  Widget createLocalizedWidgetForTesting({Widget child, String jsonFile}) {
    return EasyLocalization(
      supportedLocales: [Locale('en', 'US')],
      path: '/',
      assetLoader: JsonAssetLoader(json: jsonFile),
      child: child
    );
  }
}