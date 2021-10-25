import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/lesson_request_model.dart';
import 'package:mwb_connect_app/core/models/lesson_model.dart';
import 'package:mwb_connect_app/core/models/lesson_note_model.dart';
import 'package:mwb_connect_app/core/models/guide_tutorial_model.dart';
import 'package:mwb_connect_app/core/models/guide_recommendation_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';

class LessonRequestService {
  final ApiService _api = locator<ApiService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();

  Future<LessonRequestModel> getLessonRequest() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/lesson_request');
    LessonRequestModel lessonRequest = LessonRequestModel.fromJson(response);
    return lessonRequest;
  }

  Future<Lesson> acceptLessonRequest(String? id, Lesson? nextLesson) async {
    Map<String, dynamic> response = await _api.postHTTP(url: '/lesson_requests/$id/accept_lesson_request', data: nextLesson?.toJson());  
    nextLesson = Lesson.fromJson(response);
    return nextLesson;
  }  

  Future<void> rejectLessonRequest(String? id) async {
    await _api.putHTTP(url: '/lesson_requests/$id/reject_lesson_request', data: {});  
    return ;
  }
  
  Future<void> updateLessonRequest(String? id, LessonRequestModel lessonRequest) async {
    await _api.putHTTP(url: '/lesson_requests/$id/update_lesson_request', data: lessonRequest.toJson());  
    return ;
  }    
  
  Future<Lesson> getNextLesson() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/next_lesson');
    Lesson nextLesson = Lesson.fromJson(response);
    return nextLesson;
  }

  Future<void> cancelNextLesson(Lesson? lesson, bool? isSingleLesson) async {
    dynamic data = {};
    if (isSingleLesson == true && lesson?.isRecurrent == true) {
      Lesson lessonData = Lesson(dateTime: lesson?.dateTime);
      data = lessonData.toJson();
    }
    String? id = lesson?.id;
    await _api.putHTTP(url: '/lessons/$id/cancel_lesson', data: data);  
    return ;
  }

  Future<void> updateLessonRecurrence(Lesson lesson) async {
    String? id = lesson.id;
    await _api.putHTTP(url: '/lessons/$id/recurrence', data: lesson.toJson());  
    return ;
  }    
  
  Future<void> changeLessonUrl(String? id, String meetingUrl) async {
    Lesson lesson = Lesson(meetingUrl: meetingUrl);
    await _api.putHTTP(url: '/lessons/$id/meeting_url', data: lesson.toJson());  
    return ;
  } 

  Future<Lesson> getPreviousLesson() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/previous_lesson');
    Lesson previousLesson = Lesson.fromJson(response);
    return previousLesson;
  }
  
  Future<List<LessonNote>> getLessonsNotes(String studentId) async {
    dynamic response = await _api.getHTTP(url: '/users/$studentId/lessons_notes');
    List<LessonNote> lessonsNotes = [];
    if (response != null) {
      lessonsNotes = List<LessonNote>.from(response.map((model) => LessonNote.fromJson(model)));  
    }
    return lessonsNotes;
  }
  
  Future<List<GuideTutorial>> getGuideTutorials(String? lessonId) async {
    dynamic response = await _api.getHTTP(url: '/lessons/$lessonId/guide_tutorials');
    List<GuideTutorial> guideTutorials = [];
    if (response != null) {
      guideTutorials = List<GuideTutorial>.from(response.map((model) => GuideTutorial.fromJson(model)));
    }
    return guideTutorials;
  }
  
  Future<List<GuideRecommendation>> getGuideRecommendations(String? lessonId) async {
    dynamic response = await _api.getHTTP(url: '/lessons/$lessonId/guide_recommendations');
    List<GuideRecommendation> guideRecommendations = [];
    if (response != null) {
      guideRecommendations = List<GuideRecommendation>.from(response.map((model) => GuideRecommendation.fromJson(model)));
    }
    return guideRecommendations;
  }  

  Future<List<Skill>> getSkills(String? subfieldId) async {
    String? userId = _storageService.userId;
    dynamic response = await _api.getHTTP(url: '/users/$userId/subfields/$subfieldId/skills');
    List<Skill> skills = [];
    if (response != null) {
      skills = List<Skill>.from(response.map((model) => Skill.fromJson(model)));
    }
    return skills;
  }
  
  Future<void> addStudentSkills(String? lessonId, List<String> skills) async {
    // await _api.putHTTP(url: '/lessons/$lessonId/skills', data: skills);
    return ;
  }

  Future<void> addStudentsLessonNotes(String? lessonId, LessonNote lessonNote) async {
    await _api.postHTTP(url: '/lessons/$lessonId/notes', data: lessonNote.toJson());
    return ;
  }  
}