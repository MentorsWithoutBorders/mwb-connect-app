import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';

class ConnectWithMentorService {
  final ApiService _api = locator<ApiService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();  

  Future<StepModel> getLastStepAdded() async {
    String userId = _storageService.userId;
    http.Response response = await _api.getHTTP(url: '/users/$userId/last_step_added');
    StepModel step;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      step = StepModel.fromJson(json);
    }
    return step;
  }

  Future<List<Skill>> getSkills() async {
    String userId = _storageService.userId;
    String subfieldId = _storageService.subfieldId;
    http.Response response = await _api.getHTTP(url: '/users/$userId/subfields/$subfieldId/skills');
    List<Skill> skills = [];
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      skills = List<Skill>.from(json.map((model) => Skill.fromJson(model)));      
    }
    return skills;
  }

  Future<LessonRequestModel> getLessonRequest() async {
    String userId = _storageService.userId;
    http.Response response = await _api.getHTTP(url: '/users/$userId/lesson_request');
    LessonRequestModel lessonRequest;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      lessonRequest = LessonRequestModel.fromJson(json);
    }
    return lessonRequest;
  }

  Future<void> cancelLessonRequest(String id) async {
    await _api.putHTTP(url: '/lesson_requests/$id/cancel_lesson_request');  
    return ;
  }  
  
  Future<Lesson> getNextLesson() async {
    String userId = _storageService.userId;
    http.Response response = await _api.getHTTP(url: '/users/$userId/next_lesson');
    Lesson nextLesson;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      nextLesson = Lesson.fromJson(json);
    }
    return nextLesson;
  }   

  Future<void> cancelLesson(String id) async {
    await _api.putHTTP(url: '/lessons/$id/cancel_lesson');  
    return ;
  }

  Future<Lesson> getPreviousLesson() async {
    String userId = _storageService.userId;
    http.Response response = await _api.getHTTP(url: '/users/$userId/previous_lesson');
    Lesson previousLesson;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      previousLesson = Lesson.fromJson(json);
    }
    return previousLesson;
  }   

  Future<List<Skill>> getMentorSkills(String mentorId) async {
    String subfieldId = _storageService.subfieldId;
    http.Response response = await _api.getHTTP(url: '/users/$mentorId/subfields/$subfieldId/skills');
    List<Skill> skills = [];
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      skills = List<Skill>.from(json.map((model) => Skill.fromJson(model)));      
    }
    return skills;
  }
  
  Future<void> addSkills(List<String> skills) async {
    String userId = _storageService.userId;
    String subfieldId = _storageService.subfieldId;
    await _api.putHTTP(url: '/users/$userId/subfields/$subfieldId/skills', data: jsonEncode(skills));  
    return ;
  }

  Future<void> setMentorPresence(String id, bool isPresent) async {
    Lesson lesson = Lesson(isMentorPresent: isPresent);
    await _api.putHTTP(url: '/lessons/$id/mentor_presence', data: lesson.toJson());  
    return ;
  }
}