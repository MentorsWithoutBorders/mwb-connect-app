import 'package:sqflite/sqflite.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/common_service.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';

class GoalsService {
  final LocalStorageService _storageService = locator<LocalStorageService>();  
  final ApiService _api = locator<ApiService>();
  final CommonService _commonService = locator<CommonService>();

  Future<List<Goal>> getGoals() async {
    Database? db = await _commonService.db;
    String where = 'userId = ?';
    List<String?> whereArgs = [_storageService.userId];
    List<Map<String, Object?>> goalsList = await db!.query('goals', where: where, whereArgs: whereArgs);
    List<Goal> goals = [];
    int count = goalsList.length;
    if (count > 0) {
      for (int i = 0; i < count; i++) {
        goals.add(Goal.fromJson(goalsList[i]));
      }
    }
    return goals;
  }

  Future<void> getRemoteGoals() async {
    List<Goal> goals = [];
    dynamic response = await _api.getHTTP(url: '/goals');
    if (response != null) {
      goals = List<Goal>.from(response.map((model) => Goal.fromJson(model)));
      int count = goals.length;
      if (count > 0) {
        for (int i = 0; i < count; i++) {
          addGoal(goals[i]);
        }
      }
    }
    return ;
  }

  Future<Goal> getGoalById(String id) async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/goals/$id');
    Goal goal = Goal.fromJson(response);
    return goal;
  }

  Future<Goal> addGoal(Goal goal) async {
    Map<String, dynamic> response = await _api.postHTTP(url: '/goals', data: goal.toJson());  
    Goal addedGoal = Goal.fromJson(response);
    return addedGoal;
  }

  Future<void> updateGoal(Goal goal, String id) async {
    await _api.putHTTP(url: '/goals/$id', data: goal.toJson());  
    return ;
  }     

  Future<void> deleteGoal(String id) async {
    await _api.deleteHTTP(url: '/goals/$id');
    return ;
  } 
}