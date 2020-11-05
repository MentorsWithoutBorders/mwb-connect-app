import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'constants.dart';

class LocaleFileService
{
    static Future<Map<String, String>> getLocaleFiles(List<String> locales, String basePath) async
    {
        var localizedFiles = await _getAllLocaleFiles(basePath);

        final files = new Map<String, String>();

        for(final language in locales.toSet())
        {
            var file = _findLocaleFile(language, localizedFiles, basePath);

            files[language] = file;
        }

        return files;
    }

    static Future<String> getLocaleContent(String file) async
    {
        final directory = await getApplicationDocumentsDirectory();
        if (file.contains(directory.path)) {
          return await File(file).readAsString();
        } else {
          return await rootBundle.loadString(file);
        }
    }

    static Future<List<String>> _getAllLocaleFiles(String basePath) async
    {
        final manifest = await rootBundle.loadString(Constants.assetManifestFilename);

        Map<String, dynamic> map = jsonDecode(manifest);

        var separator = basePath.endsWith('/') ? '' : '/';

        return map.keys.where((x) => x.startsWith('$basePath$separator')).toList();
    }

    static String _findLocaleFile(String languageCode, List<String> localizedFiles, String basePath)
    {
        var file = _getFilepath(languageCode, basePath);

        if(!localizedFiles.contains(file))
        {
            if(languageCode.contains('_'))
            {
                file = _getFilepath(languageCode.split('_').first, basePath);
            }
        }

        if(file == null)
        {
            throw new Exception('The asset file for the language "$languageCode" was not found.');
        }

        return file;
    }

    static String _getFilepath(String languageCode, String basePath)
    {
        var separator = basePath.endsWith('/') ? '' : '/';

        return '$basePath$separator$languageCode.json';
    }
}
