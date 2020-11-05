import 'package:flutter_translate/flutter_translate.dart';

class TranslateService {
  LocalizationDelegate localizationDelegate;

  String getText(String text) {
    return translate(text, args: {'language': translate('language.name.${localizationDelegate.currentLocale.languageCode}')});
  }

}