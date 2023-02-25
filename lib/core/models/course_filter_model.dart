import 'package:mwb_connect_app/utils/utils_availabilities.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';

class CourseFilter {
  CourseType? courseType;
  Field? field;
  List<Availability>? availabilities;

  CourseFilter({
    this.courseType,
    this.field,
    this.availabilities
  });

  CourseFilter.fromJson(Map<String, dynamic> json) {
    courseType = json['courseType'] != null ? CourseType.fromJson(json['courseType']) : null;
    field = json['field'] != null ? Field.fromJson(json['field']) : null;
    availabilities = _availabilitiesFromJson(json['availabilities']?.cast<Map<String,dynamic>>());
  }

  List<Availability> _availabilitiesFromJson(List<Map<String, dynamic>>? json) {
    final List<Availability> availabilitiesList = [];
    if (json != null) {
      for (int i = 0; i < json.length; i++) {
        availabilitiesList.add(UtilsAvailabilities.getAvailabilityToLocal(Availability.fromJson(json[i])));
      }
    }
    return availabilitiesList;
  }  

  Map<String, Object?> toJson() {
    return {
      'courseType': courseType?.toJson(),
      'field': field?.toJson(),
      'availabilities': _availabilitiesToJson(availabilities),
    };
  }

  List<Map<String, dynamic>> _availabilitiesToJson(List<Availability>? availabilities) {
    List<Map<String,dynamic>> availabilitiesList = [];
    if (availabilities != null) {
      for (int i = 0; i < availabilities.length; i++) {
        availabilitiesList.add(UtilsAvailabilities.getAvailabilityToUtc(availabilities[i]).toJson());
      }
    }
    return availabilitiesList;
  }  
}