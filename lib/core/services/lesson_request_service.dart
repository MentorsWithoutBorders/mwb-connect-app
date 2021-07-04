import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';

class LessonRequestService {
  final ApiService _api = locator<ApiService>();

  Future<LessonRequestModel> getLessonRequest() async {
    http.Response response = await _api.getHTTP(url: '/lesson_request');
    LessonRequestModel lessonRequest;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      lessonRequest = LessonRequestModel.fromJson(json);
    }
    return lessonRequest;
  }

  Future<Lesson> acceptLessonRequest(String id, Lesson nextLesson) async {
    http.Response response = await _api.postHTTP(url: '/lesson_requests/$id/accept_lesson_request', data: nextLesson.toJson());  
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      nextLesson = Lesson.fromJson(json);
    }
    return nextLesson;
  }  

  Future<void> rejectLessonRequest(String id) async {
    await _api.putHTTP(url: '/lesson_requests/$id/reject_lesson_request', data: {});  
    return ;
  }  
  
  Future<Lesson> getNextLesson() async {
    http.Response response = await _api.getHTTP(url: '/next_lesson');
    Lesson nextLesson;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      nextLesson = Lesson.fromJson(json);
    }
    return nextLesson;
  }

  Future<void> cancelNextLesson(Lesson lesson, bool isSingleLesson) async {
    dynamic data = {};
    if (isSingleLesson && lesson.isRecurrent) {
      Lesson lessonData = Lesson(dateTime: lesson.dateTime);
      data = lessonData.toJson();
    }
    String id = lesson.id;
    await _api.putHTTP(url: '/lessons/$id/cancel_lesson', data: data);  
    return ;
  }

  Future<void> updateLessonRecurrence(Lesson lesson) async {
    String id = lesson.id;
    await _api.putHTTP(url: '/lessons/$id/update_recurrence', data: lesson.toJson());  
    return ;
  }    
  
  Future<void> changeLessonUrl(String id, String meetingUrl) async {
    Lesson lesson = Lesson(meetingUrl: meetingUrl);
    await _api.putHTTP(url: '/lessons/$id/change_meeting_url', data: lesson.toJson());  
    return ;
  } 

  Future<Lesson> getPreviousLesson() async {
    http.Response response = await _api.getHTTP(url: '/previous_lesson');
    Lesson previousLesson;
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      previousLesson = Lesson.fromJson(json);
    }
    return previousLesson;
  }    

  Future<List<Skill>> getSkills(String subfieldId) async {
    http.Response response = await _api.getHTTP(url: '/subfields/$subfieldId/skills');
    List<Skill> skills = [];
    if (response != null && response.body != null) {
      var json = jsonDecode(response.body);
      skills = List<Skill>.from(json.map((model) => Skill.fromJson(model)));      
    }
    return skills;
  }
  
  Future<void> addStudentSkills(String studentId, String subfieldId, List<String> skills) async {
    await _api.postHTTP(url: '/users/$studentId/subfields/$subfieldId/skills', data: skills);
    return ;
  }    
}