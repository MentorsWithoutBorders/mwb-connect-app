import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/services/common_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';

class StepsService {
  final LocalStorageService _storageService = locator<LocalStorageService>();
  final ApiService _api = locator<ApiService>();
  final CommonService _commonService = locator<CommonService>();


  Future<List<StepModel>> getSteps(String goalId) async {
    Database? db = await _commonService.db;
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
    Database? db = await _commonService.db;
    String where = 'userId = ?';
    List<String?> whereArgs = [_storageService.userId];
    List<Map<String, Object?>> stepsList = await db!.query('steps', where: where, whereArgs: whereArgs);
    List<StepModel> steps = [];
    int count = stepsList.length;
    if (count > 0) {
      for (int i = 0; i < count; i++) {
        // StepModel step = StepModel.fromJson(stepsList[i]);
        // await this.deleteStep(step.id as String);
        steps.add(StepModel.fromJson(stepsList[i]));
      }
    }
    return steps;
  }

  Future<void> getRemoteSteps() async {
    List<StepModel> steps = [];    
    dynamic response = await _api.getHTTP(url: '/steps/all');
    if (response != null) {
      steps = List<StepModel>.from(response.map((model) => StepModel.fromJson(model)));
      int count = steps.length;
      if (count > 0) {
        for (int i = 0; i < count; i++) {
          // addStep(goalId, steps[i]);
        }
      }        
    }    
  }

  Future<StepModel> getStepById(String goalId, String id) async {
    Database? db = await _commonService.db;
    List<Map<String, Object?>> stepById = await db!.query('steps', where: 'id = ?', whereArgs: [id]);
    return StepModel.fromJson(stepById.first);
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
    Database? db = await _commonService.db;
    await db!.insert('steps', step.toJson());
    return step;
  }

  Future<void> updateStep(StepModel step, String? id) async {
    Database? db = await _commonService.db;
    await db!.update('steps', step.toJson(), where: 'id = ?', whereArgs: [step.id]);
    return ;
  }  

  Future<void> deleteStep(String id) async {
    Database? db = await _commonService.db;
    await db!.delete('steps',  where: 'id = ?', whereArgs: [id]);
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