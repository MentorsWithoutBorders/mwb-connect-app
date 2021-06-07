import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/tutorial_model.dart';
import 'package:mwb_connect_app/core/models/quiz_settings_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class DownloadService { 
  final ApiService _api = locator<ApiService>();

  Future<void> initAppDirectory() async {
    await _createDir('i18n');
    await _createDir('images');

    await _copyLocaleFile('en-US');
  }

  Future<void> downloadLocales() async {
    await _downloadLocaleFile('en-US');
    // String currentLocale = await Devicelocale.currentLocale;
    // if (currentLocale.indexOf('_') > -1) {
    //   await _downloadLocaleFile(currentLocale.split('_')[0]);
    // } else {
    //   await _downloadLocaleFile(currentLocale);
    // }
  }

  Future<void> _createDir(String dirToBeCreated) async {
    final Directory baseDir = await getApplicationDocumentsDirectory(); 
    final String finalDir = join(baseDir.path, dirToBeCreated);
    final Directory dir = Directory(finalDir);
    final bool dirExists = await dir.exists();
    if (!dirExists) {
      dir.create();
    }
  } 

  Future<void> _copyLocaleFile(String locale) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String fileAssetsPath = 'assets/i18n/' + locale + '.json';
    final String fileAppDirPath = directory.path + '/i18n/' + locale + '.json';
    //if (FileSystemEntity.typeSync(fileAppDirPath) == FileSystemEntityType.notFound) {
      final ByteData data = await rootBundle.load(fileAssetsPath);
      final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(fileAppDirPath).writeAsBytes(bytes);
    //}
  }
  
  Future<void> _downloadLocaleFile(String fileName) async {   
    final Directory directory = await getApplicationDocumentsDirectory();
    final String fileAppDirPath = directory.path + '/i18n/' + fileName + '.json';     
    final Reference ref = FirebaseStorage.instance.ref().child('i18n').child(fileName + '.json');
    try {  
      await ref.getMetadata().then((FullMetadata value) async {
        final File fileAppDir = File(fileAppDirPath);
        if (FileSystemEntity.typeSync(fileAppDirPath) == FileSystemEntityType.notFound) {
          await _createFile(fileAppDir);
          await _getFileFromCloudstore(ref, fileAppDirPath);
        } else {
          if (value.size != fileAppDir.lengthSync()) {
            await _deleteFile(fileAppDir);
            await _createFile(fileAppDir);
            await _getFileFromCloudstore(ref, fileAppDirPath);
          }
        }
      });
    } on Exception catch(e) {
      print(e);
    }
  }

  Future<void> _createFile(File file) async {
    await file.create();
  }

  Future<void> _deleteFile(File file) async {
    await file.delete();
  }  

  Future<void> _getFileFromCloudstore(ref, String fileAppDirPath) async {
    final String url = await ref.getDownloadURL();
    final http.Response downloadData = await http.get(Uri.parse(url));
    final File file = File(fileAppDirPath);
    file.writeAsString(utf8.decode(downloadData.bodyBytes));
  }

  Future<void> setPreferences() async {
    final LocalStorageService storageService = locator<LocalStorageService>();
    // Set tutorial sections
    final List<Tutorial> tutorialsList = await _getTutorials();
    final Map<String, List<String>> tutorials = {};
    tutorialsList.forEach((tutorial) { 
      tutorials[tutorial.type] = tutorial.sections;
    });
    if (tutorials.isNotEmpty) {
      storageService.tutorials = tutorials;
    }  
    // Get quizzes settings
    final QuizSettings quizSettings = await _getQuizSettings();
    if (quizSettings != null) {
      if (quizSettings.count != 0) {
        storageService.quizzesCount = quizSettings.count;
      }
      if (quizSettings.rounds != 0) {
        storageService.quizzesRounds = quizSettings.rounds;
      }
      if (quizSettings.timeBetweenRounds != 0) {
        storageService.timeBetweenQuizzesRounds = quizSettings.timeBetweenRounds;
      }
      storageService.showQuizTimer = quizSettings.showTimer;
    }  
    debugPrint('preferences were set');
  }

  Future<void> getImages() async {
    final LocalStorageService storageService = locator<LocalStorageService>();
    final Map<String, dynamic> tutorials = storageService.tutorials;
    for (final MapEntry<String, dynamic> entry in tutorials.entries) {
      final List<String> sections = entry.value.cast<String>(); 
      for (final String section in sections) {
        String image;
        if (section == 'main') {
          image = entry.key;
        } else {
          image = section;
        }
        try {
          await _checkImage(image);
        } on Exception catch(e) {
          print(e);
        }
      }
    }
  }
  
  Future<void> _checkImage(String image) async {
    final Directory directory = await getApplicationDocumentsDirectory();    
    final Reference ref = FirebaseStorage.instance.ref().child('images').child(image + '.png');
    final String url = await ref.getDownloadURL();
    final String localImage = directory.path +'/images/' + image + '.png';    
    await ref.getMetadata().then((FullMetadata value) async {
      final int remoteImageSize = value.size;
      int localImageSize = 0;
      final File localImageFile = File(localImage);
      if (localImageFile.existsSync()) {
        localImageSize = await localImageFile.length();
      }
      if (localImageSize != remoteImageSize) {
        await _downloadImage(url, localImageFile);
      }
    }); 
  }

  Future<void> _downloadImage(String url, File file) async {
    final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();
    try {
      assert(url != null && url.isNotEmpty);

      final Uri resolved = Uri.base.resolve(url);
      final HttpClientRequest request = await HttpClient().getUrl(resolved);

      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok)
        throw NetworkImageLoadException(statusCode: response.statusCode, uri: resolved);

      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },        
      );
      if (bytes.lengthInBytes == 0) {
        throw Exception('NetworkImage is an empty file: $resolved');
      }

      if (file != null) {
        file.writeAsBytes(bytes, flush: true);
      }
    } finally {
      chunkEvents.close();
    }
  }

  Future<List<Tutorial>> _getTutorials() async {
    http.Response response = await _api.getHTTP(url: '/tutorials');
    List<Tutorial> tutorials = [];
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      tutorials = List<Tutorial>.from(json.map((model) => Tutorial.fromJson(model)));      
    }
    return tutorials;
  }

  Future<QuizSettings> _getQuizSettings() async {
    http.Response response = await _api.getHTTP(url: '/quizzes_settings');
    QuizSettings quizSettings;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      quizSettings = QuizSettings.fromJson(json);
    }
    return quizSettings;
  } 

  Future<void> showFiles() async {
    final Directory directory = await getApplicationDocumentsDirectory();

    final List<FileSystemEntity> files = Directory(directory.path + '/i18n').listSync();
    // await Future.forEach(files, (file) async {
    //   await file.deleteSync();
    // });
   
    files.forEach((FileSystemEntity file) {
      print(file);
    });
  }

}