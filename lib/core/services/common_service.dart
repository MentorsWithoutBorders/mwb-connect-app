import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class CommonService {
  static Database? _db;

  Future<Database> initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + '/mwbconnect.db';
    var db = openDatabase(path, version: 1, onCreate: _createDb);
    return db;
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS steps(
        id VARCHAR(255) PRIMARY KEY,
        userId VARCHAR(255),
        goalId VARCHAR(255),
        text TEXT,
        position INTEGER,
        level INTEGER,
        parentId VARCHAR(255),
        dateTime VARCHAR(255)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS goals(
        id VARCHAR(255) PRIMARY KEY,
        userId VARCHAR(255),
        text TEXT,
        position INTEGER,
        dateTime VARCHAR(255)
      )
    ''');    
  }

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initDb();
    }
    Directory directory = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> entities = Directory(directory.path).listSync();
    final Iterable<File> files = entities.whereType<File>();
    files.forEach((FileSystemEntity file) {
      // file.deleteSync();
      print(file);
    });
    return _db;
  }

}
