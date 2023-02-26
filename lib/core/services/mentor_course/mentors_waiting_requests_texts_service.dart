import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/models/mentor_waiting_request_model.dart';

class MentorsWaitingRequestsTextsService {

  String getCourseTypeText(MentorWaitingRequest mentorWaitingRequest) {
    String courseType = '';
    if (mentorWaitingRequest.courseType != null) {
      courseType = mentorWaitingRequest.courseType?.duration.toString() as String;
      courseType += '-' + plural('month', 1) + ' ' + plural('course', 1);
    }
    return courseType;
  }  
}
