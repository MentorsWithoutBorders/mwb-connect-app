import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:devicelocale/devicelocale.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/tutorial_model.dart';
import 'package:mwb_connect_app/core/models/quiz_settings_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class DownloadService { 
  Api _api = locator<Api>();

  initAppDirectory() async {
    await _createDir('i18n');
    await _createDir('images');

    await _copyLocaleFile('en-US');
  }

  downloadLocales() async {
    await _downloadLocaleFile('en-US');
    // String currentLocale = await Devicelocale.currentLocale;
    // if (currentLocale.indexOf('_') > -1) {
    //   await _downloadLocaleFile(currentLocale.split('_')[0]);
    // } else {
    //   await _downloadLocaleFile(currentLocale);
    // }
  }

  _createDir(String dirToBeCreated) async {
    Directory baseDir = await getApplicationDocumentsDirectory(); 
    String finalDir = join(baseDir.path, dirToBeCreated);
    Directory dir = Directory(finalDir);
    bool dirExists = await dir.exists();
    if (!dirExists) {
      dir.create();
    }
  } 

  _copyLocaleFile(String locale) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String fileAssetsPath = 'assets/i18n/' + locale + '.json';
    String fileAppDirPath = directory.path + '/i18n/' + locale + '.json';
    //if (FileSystemEntity.typeSync(fileAppDirPath) == FileSystemEntityType.notFound) {
      ByteData data = await rootBundle.load(fileAssetsPath);
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(fileAppDirPath).writeAsBytes(bytes);
    //}
  }
  
  _downloadLocaleFile(String fileName) async {   
    Directory directory = await getApplicationDocumentsDirectory();
    String fileAppDirPath = directory.path + '/i18n/' + fileName + '.json';     
    final Reference ref = FirebaseStorage.instance.ref().child('i18n').child(fileName + '.json');
    try {  
      await ref.getMetadata().then((value) async {
        File fileAppDir = File(fileAppDirPath);
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

  _createFile(File file) async {
    await file.create();
  }

  _deleteFile(File file) async {
    await file.delete();
  }  

  _getFileFromCloudstore(ref, String fileAppDirPath) async {
    final String url = await ref.getDownloadURL();
    final http.Response downloadData = await http.get(Uri.dataFromString(url));
    File file = File(fileAppDirPath);
    file.writeAsString(utf8.decode(downloadData.bodyBytes));
  }

  setPreferences() async {
    LocalStorageService storageService = locator<LocalStorageService>();
    // Set tutorial sections
    Tutorial previews = await _getTutorial('previews');
    List<String> sections = previews.sections;
    Map<String, List<String>> tutorials = Map();
    await Future.forEach(sections, (section) async {
      Tutorial tutorial = await _getTutorial(section);
      tutorials[section] = tutorial.sections;
    });
    if (tutorials.isNotEmpty) {
      storageService.tutorials = tutorials;
    }  
    // Get quizzes settings
    QuizSettings quizSettings = await _getQuizSettings();
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

  getImages() async {
    LocalStorageService storageService = locator<LocalStorageService>();
    Map<String, dynamic> tutorials = storageService.tutorials;
    for (var entry in tutorials.entries) {
      List<String> sections = entry.value.cast<String>(); 
      for (var section in sections) {
        String image;
        if (section == 'main') {
          image = entry.key;
        } else {
          image = section;
        }
        try {
          await _checkImage(image);
        } on Exception catch(e) {}
      }
    }
  }
  
  _checkImage(String image) async {
    Directory directory = await getApplicationDocumentsDirectory();    
    Reference ref = FirebaseStorage.instance.ref().child('images').child(image + '.png');
    String url = await ref.getDownloadURL();
    String localImage = directory.path +'/images/' + image + '.png';    
    ref.getMetadata().then((value) async {
      int remoteImageSize = value.size;
      int localImageSize = 0;
      File localImageFile = File(localImage);
      if (localImageFile.existsSync()) {
        localImageSize = await localImageFile.length();
      }
      if (localImageSize != remoteImageSize) {
        _downloadImage(url, localImageFile);
      }
    }); 
  }

  _downloadImage(String url, File file) async {
    StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();
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

      if (file != null) file.writeAsBytes(bytes, flush: true);
    } finally {
      chunkEvents.close();
    }
  }

  Future<Tutorial> _getTutorial(String type) async {
    DocumentSnapshot doc = await _api.getDocumentById(path: 'tutorials', isForUser: false, id: type);
    return Tutorial.fromMap(doc.data(), doc.id);    
  }

  Future<QuizSettings> _getQuizSettings() async {
    DocumentSnapshot doc = await _api.getDocumentById(path: 'quizzes', isForUser: false, id: 'settings');
    return QuizSettings.fromMap(doc.data(), doc.id) ;
  } 

  showFiles() async {
    final directory = await getApplicationDocumentsDirectory();

    List<FileSystemEntity> files = Directory('${directory.path}' + '/i18n').listSync();
    // await Future.forEach(files, (file) async {
    //   await file.deleteSync();
    // });
   
    files.forEach((file) {
      print(file);
    });

  }

}