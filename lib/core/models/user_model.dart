import 'package:intl/intl.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/models/organization_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';
import 'package:mwb_connect_app/core/models/timezone_model.dart';

class User {
  String id;
  String name;
  String email;
  String password;
  bool isMentor;
  Organization organization;
  Field field;
  List<Subfield> subfields;
  TimeZoneModel timeZone;
  List<Availability> availabilities;
  bool isAvailable;
  DateTime availableFrom;
  LessonsAvailability lessonsAvailability;
  DateTime registeredOn;

  User({this.id, this.name, this.email, this.password, this.isMentor, this.organization, this.field, this.subfields, this.timeZone, this.availabilities, this.isAvailable, this.availableFrom, this.lessonsAvailability, this.registeredOn});

  User.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat); 
    id = json['id'].toString() ?? '';
    name = json['name'].toString() ?? '';
    email = json['email'].toString() ?? '';
    password = json['password'].toString() ?? '';
    isMentor = json['isMentor'] ?? false;
    organization = _organizationFromJson(json['organization']);
    field = _fieldFromJson(json['field']);
    timeZone = _timeZoneFromJson(json['timeZone']);
    availabilities = _availabilitiesFromJson(json['availabilities']?.cast<Map<String,dynamic>>()) ?? [];
    isAvailable = json['isAvailable'] ?? true;
    availableFrom = json['availableFrom'] != null ? dateFormat.parseUTC(json['availableFrom']).toLocal() : null;
    lessonsAvailability = _lessonsAvailabilityFromJson(json['lessonsAvailability']);
    registeredOn = json['registeredOn'] != null ? dateFormat.parseUTC(json['registeredOn']).toLocal() : null;
  }

  Organization _organizationFromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    Organization organization = Organization.fromJson(json);
    return organization;
  }   

  Field _fieldFromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    Field field = Field.fromJson(json);
    return field;
  }  
  
  TimeZoneModel _timeZoneFromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    TimeZoneModel timezone = TimeZoneModel(name: json['name'], abbreviation: json['abbreviation'], offset: json['offset']);
    return timezone;
  }  
  
  List<Availability> _availabilitiesFromJson(List<Map<String, dynamic>> json) {
    final List<Availability> availabilityList = [];
    if (json != null) {
      for (int i = 0; i < json.length; i++) {
        availabilityList.add(Availability(dayOfWeek: json[i]['dayOfWeek'], time: Time(from: json[i]['time']['from'], to: json[i]['time']['to'])));
      }
    }
    return availabilityList;
  }

  LessonsAvailability _lessonsAvailabilityFromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    LessonsAvailability lessonsAvailability = LessonsAvailability(minInterval: json['minInterval'], minIntervalUnit: json['minIntervalUnit'], maxStudents: json['maxStudents']);
    return lessonsAvailability;
  }

  Map<String, Object> toJson() {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat); 
    Map<String, Object> userMap = {
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
      'availableFrom': availableFrom != null ? dateFormat.format(availableFrom) : null,
      'registeredOn': registeredOn != null ? dateFormat.format(registeredOn) : null,
    };
    if (_lessonsAvailabilityToJson(lessonsAvailability) != null) {
      userMap.putIfAbsent('lessonsAvailability', () => _lessonsAvailabilityToJson(lessonsAvailability));
    }
    return userMap;
  } 

  List<Map<String, dynamic>> _availabilitiesToJson(List<Availability> availabilities) {
    List<Map<String,dynamic>> availabilityList = [];
    if (availabilities != null) {
      for (int i = 0; i < availabilities.length; i++) {
        availabilityList.add({
          'dayOfWeek': availabilities[i].dayOfWeekToEng, 
          'time': {
            'from': availabilities[i].time.from,
            'to': availabilities[i].time.to
          }
        });
      }
    }
    return availabilityList;
  }
  
  Map<String, dynamic> _timeZoneToJson(TimeZoneModel timezone) {
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

  Map<String, dynamic> _lessonsAvailabilityToJson(LessonsAvailability lessonsAvailability) {
    if (lessonsAvailability != null) {
      return {
        'minInterval': lessonsAvailability.minInterval,
        'minIntervalUnit': lessonsAvailability.minIntervalUnitToEng,
        'maxStudents': lessonsAvailability.maxStudents,
      };
    } else {
      return null;
    }
  }  
}

class LessonsAvailability {
  int minInterval;
  String minIntervalUnit;
  int maxStudents;

  LessonsAvailability({this.minInterval, this.minIntervalUnit, this.maxStudents}) {
    if (minIntervalUnit != null) {
      minIntervalUnit = Utils.translatePeriodUnitFromEng(minIntervalUnit);
    }
  }

  String get minIntervalUnitToEng => Utils.translatePeriodUnitToEng(minIntervalUnit);  
}