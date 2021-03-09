import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/goal_model.dart';

class GoalsService {
  Api _api = locator<Api>();

  Future<List<Goal>> fetchGoals() async {
    QuerySnapshot result = await _api.getDataCollection(path: 'goals', isForUser: true);
    List<Goal> goals = result.docs
        .map((doc) => Goal.fromMap(doc.data(), doc.id))
        .toList();
    return goals;
  }

  Stream<QuerySnapshot> fetchGoalsAsStream() {
    return _api.streamDataCollection(path: 'goals', isForUser: true);
  }

  Future<Goal> getGoalById(String id) async {
    DocumentSnapshot doc = await _api.getDocumentById(path: 'goals', isForUser: true, id: id);
    return Goal.fromMap(doc.data(), doc.id);
  }

  Future deleteGoal(String id) async {
    await _api.removeSubCollection(path: 'goals/' + id + '/steps', isForUser: true);    
    await _api.removeDocument(path: 'goals', isForUser: true, id: id);
    return ;
  }

  Future updateGoal(Goal goal, String id) async {
    await _api.updateDocument(path: 'goals', isForUser: true, data: goal.toJson(), id: id);
    return ;
  }  

  Future<Goal> addGoal(Goal goal) async {
    DocumentReference doc = await _api.addDocument(path: 'goals', isForUser: true, data: goal.toJson());
    Goal addedGoal = await doc.get().then((datasnapshot) {
      if (datasnapshot.exists) {
        Goal goal = Goal(id: doc.id, text: datasnapshot.data()['text'], index: datasnapshot.data()['index']);
        return goal;
      } else {
        return Goal();
      }
    });    
    return addedGoal;
  }
}