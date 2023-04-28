import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';

class NotificationsSettings {
  bool? trainingRemindersEnabled;
  String? trainingRemindersTime;
  bool? startCourseRemindersEnabled;
  DateTime? startCourseRemindersDate;  

  NotificationsSettings({this.trainingRemindersEnabled, this.trainingRemindersTime, this.startCourseRemindersEnabled, this.startCourseRemindersDate});

  NotificationsSettings.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
    trainingRemindersEnabled = json['trainingRemindersEnabled'] ?? true;
    trainingRemindersTime = json['trainingRemindersTime'];
    startCourseRemindersEnabled = json['startCourseRemindersEnabled'] ?? true;
    startCourseRemindersDate = json['startCourseRemindersDate'] != null ? dateFormat.parseUTC(json['startCourseRemindersDate']).toLocal() : null;
  }

  Map<String, Object?> toJson() {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en'); 
    return {
      'trainingRemindersEnabled': trainingRemindersEnabled,
      'trainingRemindersTime': trainingRemindersTime,
      'startCourseRemindersEnabled': startCourseRemindersEnabled,
      'startCourseRemindersDate': startCourseRemindersDate != null ? dateFormat.format(startCourseRemindersDate!.toUtc()) : null
    };
  }
}