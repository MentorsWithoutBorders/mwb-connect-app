import 'package:mwb_connect_app/core/models/organization_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/timezone_model.dart';

class CourseMentor extends User {
  String? meetingUrl;
  bool? isCanceled;

  CourseMentor({
    String? id,
    String? name,
    String? email,
    String? password,
    bool? isMentor,
    Organization? organization,
    Field? field,
    TimeZoneModel? timeZone,
    List<Availability>? availabilities,
    bool? isAvailable,
    DateTime? availableFrom,
    LessonsAvailability? lessonsAvailability,
    DateTime? registeredOn,
    bool? hasScheduledLesson,
    this.meetingUrl,
    this.isCanceled,
  }) : super(
          id: id,
          name: name,
          email: email,
          password: password,
          isMentor: isMentor,
          organization: organization,
          field: field,
          timeZone: timeZone,
          availabilities: availabilities,
          isAvailable: isAvailable,
          availableFrom: availableFrom,
          lessonsAvailability: lessonsAvailability,
          registeredOn: registeredOn,
          hasScheduledLesson: hasScheduledLesson,
        );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['meetingUrl'] = meetingUrl;
    json['isCanceled'] = isCanceled;
    return json;
  }

  static CourseMentor fromJson(Map<String, dynamic> json) {
    User user = User.fromJson(json);
    return CourseMentor(
      id: user.id,
      name: user.name,
      email: user.email,
      password: user.password,
      isMentor: user.isMentor,
      organization: user.organization,
      field: user.field,
      timeZone: user.timeZone,
      availabilities: user.availabilities,
      isAvailable: user.isAvailable,
      availableFrom: user.availableFrom,
      lessonsAvailability: user.lessonsAvailability,
      registeredOn: user.registeredOn,
      hasScheduledLesson: user.hasScheduledLesson,
      meetingUrl: json['meetingUrl'],
      isCanceled: json['isCanceled'],
    );
  }
}