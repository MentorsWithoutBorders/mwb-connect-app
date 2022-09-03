import 'dart:io';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';

class StepsService {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final ApiService _api = locator<ApiService>();
  static Database? _db;

  Future<Database> initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + '/mwbconnect.db';
    var db = openDatabase(path, version: 1, onCreate: _createDb);
    return db;
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE steps(
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
    print('Steps table has been created');
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

  Future<List<StepModel>> getSteps(String goalId) async {
    Database? db = await this.db;
    String where = 'userId = ? AND goalId = ?';
    List<String?> whereArgs = [_storageService.userId, goalId];
    // List<Map<String, Object?>> stepsList = await db!.query('steps');
    List<Map<String, Object?>> stepsList = await db!.query('steps', where: where, whereArgs: whereArgs);
    List<StepModel> steps = [];
    int count = stepsList.length;
    if (count > 0) {
      for (int i = 0; i < count; i++) {
        steps.add(StepModel.fromJson(stepsList[i]));
      }
    }
    return steps;
  }

  Future<List<StepModel>> getAllSteps() async {
    Database? db = await this.db;
    String where = 'userId = ?';
    List<String?> whereArgs = [_storageService.userId];
    List<Map<String, Object?>> stepsList = await db!.query('steps', where: where, whereArgs: whereArgs);
    List<StepModel> steps = [];
    int count = stepsList.length;
    if (count > 0) {
      for (int i = 0; i < count; i++) {
        steps.add(StepModel.fromJson(stepsList[i]));
      }
    } else {
      // dynamic response = await _api.getHTTP(url: '/steps/all');
      // if (response != null) {
      //   steps = List<StepModel>.from(response.map((model) => StepModel.fromJson(model)));
      //   int count = steps.length;
      //   if (count > 0) {
      //     for (int i = 0; i < count; i++) {
      //       addStep(steps[i].goalId, steps[i]);
      //     }
      //   }        
      // }
    }
    return steps;
  }

  Future<StepModel> getStepById(String goalId, String id) async {
    Database? db = await this.db;
    List<Map<String, Object?>> stepById = await db!.query('steps', where: 'id = ?', whereArgs: [id]);
    return StepModel.fromJson(stepById.first);

    // Map<String, dynamic> response = await _api.getHTTP(url: '/steps/$id');
    // StepModel step = StepModel.fromJson(response);
    // return step;
  }

  Future<StepModel> getLastStepAdded() async {
    List<StepModel> steps = await this.getAllSteps();
    steps.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
    StepModel lastStepAdded = StepModel();
    if (steps.length > 0) {
      lastStepAdded = steps[steps.length - 1];
      DateTime now = Utils.resetTime(DateTime.now());
      DateTime registeredOn = Utils.resetTime(DateTime.parse(_storageService.registeredOn as String));
      int timeSinceRegistration = Utils.getDSTAdjustedDifferenceInDays(now, registeredOn);
      bool isMentor = _storageService.isMentor as bool;
      if (isMentor && timeSinceRegistration > AppConstants.mentorWeeksTraining * 7 ||
          !isMentor && timeSinceRegistration > AppConstants.studentWeeksTraining * 7) {
        lastStepAdded.dateTime = DateTime.now();
      }
    }

    // Map<String, dynamic> response = await _api.getHTTP(url: '/last_step_added');
    // StepModel step = StepModel.fromJson(response);
    return lastStepAdded;
  }    

  Future<StepModel> addStep(String? goalId, StepModel step) async {
    Uuid uuid = Uuid();
    String id = uuid.v4();
    if (step.id == null) {
      step.id = id;
    }
    step.userId = _storageService.userId;
    step.goalId = goalId;
    if (step.dateTime == null) {
      step.dateTime = DateTime.now();
    }
    Database? db = await this.db;
    await db!.insert('steps', step.toJson());

    // Map<String, dynamic> response = await _api.postHTTP(url: '/goals/$goalId/steps', data: step.toJson());
    // StepModel addedStep = StepModel.fromJson(response);
    return step;
  }

  Future<void> updateStep(StepModel step, String? id) async {
    Database? db = await this.db;
    int count = await db!.update('steps', step.toJson(),
        where: 'id = ?', whereArgs: [step.id]);
    print('Step updated: ' + count.toString());

    // await _api.putHTTP(url: '/steps/$id', data: step.toJson());
    return ;
  }  

  Future<void> deleteStep(String id) async {
    Database? db = await this.db;
    await db!.delete('steps',  where: 'id = ?', whereArgs: [id]);
    List<StepModel> steps = await getAllSteps();
    print(steps);

    // await _api.deleteHTTP(url: '/steps/$id');
    return ;
  }
  
  Future<void> sendSteps(String? goalId, List<StepModel>? steps) async {
    if (steps != null && steps.length > 0) {
      await deleteSteps(goalId, steps);
      for (StepModel step in steps) {
        await _api.postHTTP(url: '/goals/$goalId/steps', data: step.toJson());
      }
    }
    return ;
  }

  Future<void> deleteSteps(String? goalId, List<StepModel>? steps) async {
    if (steps != null && steps.length > 0) {
      await _api.deleteHTTP(url: '/goals/$goalId/steps');
    }
    return ;
  }   
}