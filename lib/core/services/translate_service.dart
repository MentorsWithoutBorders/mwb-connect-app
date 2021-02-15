import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class TranslateService {
  LocalizationDelegate localizationDelegate;

  String getText(String text) {
    return translate(text, args: {'language': translate('language.name.${localizationDelegate.currentLocale.languageCode}')});
  }

  String getTextWithContext(BuildContext context, String text) {
    localizationDelegate = LocalizedApp.of(context).delegate;
    return translate(text, args: {'language': translate('language.name.${localizationDelegate.currentLocale.languageCode}')});
  }  

}