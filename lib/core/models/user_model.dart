import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils_availabilities.dart';
import 'package:mwb_connect_app/core/models/organization_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/timezone_model.dart';

class User {
  String? id;
  String? name;
  String? email;
  String? password;
  bool? isMentor;
  Organization? organization;
  Field? field;
  TimeZoneModel? timeZone;
  List<Availability>? availabilities;
  bool? isAvailable;
  DateTime? availableFrom;
  LessonsAvailability? lessonsAvailability;
  DateTime? registeredOn;
  bool? hasScheduledLesson;

  User({this.id, this.name, this.email, this.password, this.isMentor, this.organization, this.field, this.timeZone, this.availabilities, this.isAvailable, this.availableFrom, this.lessonsAvailability, this.registeredOn, this.hasScheduledLesson});

  User.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en'); 
    id = json['id'].toString();
    name = json['name'].toString();
    email = json['email'].toString();
    password = json['password'].toString();
    isMentor = json['isMentor'] ?? false;
    organization = _organizationFromJson(json['organization']);
    field = _fieldFromJson(json['field']);
    timeZone = _timeZoneFromJson(json['timeZone']);
    availabilities = _availabilitiesFromJson(json['availabilities']?.cast<Map<String,dynamic>>());
    isAvailable = json['isAvailable'] ?? true;
    availableFrom = json['availableFrom'] != null ? dateFormat.parseUTC(json['availableFrom']).toLocal() : null;
    lessonsAvailability = _lessonsAvailabilityFromJson(json['lessonsAvailability'], isMentor!);
    registeredOn = json['registeredOn'] != null ? dateFormat.parseUTC(json['registeredOn']).toLocal() : null;
    hasScheduledLesson = json['hasScheduledLesson'] ?? false;
  }

  Organization _organizationFromJson(Map<String, dynamic> json) {
    Organization organization = Organization.fromJson(json);
    return organization;
  }   

  Field? _fieldFromJson(Map<String, dynamic>? json) {
    if (json != null) {
      return Field.fromJson(json);
    }
  }  
  
  TimeZoneModel _timeZoneFromJson(Map<String, dynamic>? json) {
    TimeZoneModel timezone = TimeZoneModel(name: json?['name'], abbreviation: json?['abbreviation'], offset: json?['offset']);
    return timezone;
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

  LessonsAvailability? _lessonsAvailabilityFromJson(Map<String, dynamic>? json, bool isMentor) {
    LessonsAvailability? lessonsAvailability;
    if (isMentor) {
      lessonsAvailability = LessonsAvailability(maxStudents: json?['maxStudents']);
    }
    return lessonsAvailability;
  }

  Map<String, Object?> toJson() {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en'); 
    Map<String, Object?> userMap = {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'isMentor': isMentor,
      'organization': organization?.toJson(),
      'field': field?.toJson(),
      'timeZone': _timeZoneToJson(timeZone),
      'availabilities': _availabilitiesToJson(availabilities),
      'isAvailable': isAvailable,
      'availableFrom': availableFrom != null ? dateFormat.format(availableFrom!.toUtc()) : null,
      'registeredOn': registeredOn != null ? dateFormat.format(registeredOn!.toUtc()) : null,
      'hasScheduledLesson': hasScheduledLesson
    };
    if (_lessonsAvailabilityToJson(lessonsAvailability) != null) {
      userMap.putIfAbsent('lessonsAvailability', () => _lessonsAvailabilityToJson(lessonsAvailability));
    }
    return userMap;
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
  
  Map<String, dynamic>? _timeZoneToJson(TimeZoneModel? timezone) {
    if (timezone != null) {
      return {
        'name': timezone.name,
        'abbreviation': timezone.abbreviation,
        'offset': timezone.offset
      };
    } else {
      return null;
    }
  }    

  Map<String, dynamic>? _lessonsAvailabilityToJson(LessonsAvailability? lessonsAvailability) {
    if (lessonsAvailability != null && lessonsAvailability.maxStudents != null) {
      return {
        'maxStudents': lessonsAvailability.maxStudents,
      };
    } else {
      return null;
    }
  }  
}

class LessonsAvailability {
  int? maxStudents;

  LessonsAvailability({this.maxStudents}) {}
}