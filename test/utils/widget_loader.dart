import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'test_app.dart';
import 'json_asset_loader.dart';

class WidgetLoader {
  Widget createWidget({Widget widget, String jsonFile}) {
    return createLocalizedWidgetForTesting(
      child: TestApp(
        widget: Scaffold(
          body: widget
        )
      ),
      jsonFile: jsonFile
    );
  } 

  Widget createLocalizedWidgetForTesting({Widget child, String jsonFile}) {
    return EasyLocalization(
      supportedLocales: [Locale('en', 'US')],
      path: '/',
      assetLoader: JsonAssetLoader(json: jsonFile),
      child: child
    );
  }

  EasyLocalizationController createEasyLocalizationController({String jsonFile}) {
    return EasyLocalizationController(
      supportedLocales: [Locale('en', 'US')],
      path: '/',
      useOnlyLangCode: false,
      useFallbackTranslations: false,
      onLoadError: (FlutterError e) {
        log(e.toString());
      },
      saveLocale: false,
      assetLoader: JsonAssetLoader(json: jsonFile)
    );
  }  
}