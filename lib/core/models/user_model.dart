import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';
import 'package:mwb_connect_app/core/models/timezone_model.dart';

class User {
  String id;
  String name;
  String email;
  String password;
  bool isMentor;
  String organization;
  Field field;
  List<Subfield> subfields;
  TimeZoneModel timezone;
  List<Availability> availabilities;
  bool isAvailable;
  DateTime availableFrom;
  LessonsAvailability lessonsAvailability;
  DateTime registeredOn;

  User({this.id, this.name, this.email, this.password, this.isMentor, this.organization, this.field, this.subfields, this.timezone, this.availabilities, this.isAvailable, this.availableFrom, this.lessonsAvailability, this.registeredOn});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString() ?? '';
    name = json['name'].toString() ?? '';
    email = json['email'].toString() ?? '';
    password = json['password'].toString() ?? '';
    isMentor = json['isMentor'] ?? false;
    organization = json['organization'].toString() ?? '';
    field = _fieldFromJson(json['field']) ?? null;;
    subfields = subfieldsFromJson(json['subfields']?.cast<Map<String,dynamic>>()) ?? [];
    timezone = _timezoneFromJson(json['timezone']) ?? null;
    availabilities = _availabilityFromJson(json['availabilities']?.cast<Map<String,dynamic>>()) ?? [];
    isAvailable = json['isAvailable'] ?? true;
    availableFrom = json['availableFrom']?.toDate();
    lessonsAvailability = _lessonsAvailabilityFromJson(json['lessonsAvailability']) ?? null;
    registeredOn = json['registeredOn']?.toDate();
  }

  Field _fieldFromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    Field field = Field(id: json['id'], name: json['name']);
    return field;
  }  

  List<Subfield> subfieldsFromJson(List<Map<String, dynamic>> json) {
    final List<Subfield> subfieldsList = [];
    if (json != null) {
      for (int i = 0; i < json.length; i++) {
        subfieldsList.add(Subfield.fromJson(json[i]));
      }
    }
    return subfieldsList;
  }
  
  TimeZoneModel _timezoneFromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    TimeZoneModel timezone = TimeZoneModel(name: json['name'], abbreviation: json['abbreviation'], offset: json['offset']);
    return timezone;
  }  
  
  List<Availability> _availabilityFromJson(List<Map<String, dynamic>> json) {
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
    LessonsAvailability lessonsAvailability = LessonsAvailability(minInterval: json['minInterval'], minIntervalUnit: json['minIntervalUnit']);
    return lessonsAvailability;
  }

  Map<String, Object> toJson() {
    Map<String, Object> userMap = {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'isMentor': isMentor,
      'organization': organization,
      'field': _fieldToJson(field),
      'subfields': _subfieldsToJson(subfields),
      'timezone': _timezoneToJson(timezone),
      'availabilities': _availabilityToJson(availabilities),
      'isAvailable': isAvailable,
      'availableFrom': availableFrom,
      'registeredOn': registeredOn
    };
    if (_lessonsAvailabilityToJson(lessonsAvailability) != null) {
      userMap.putIfAbsent('lessonsAvailability', () => _lessonsAvailabilityToJson(lessonsAvailability));
    }
    return userMap;
  }

  Map<String, dynamic> _fieldToJson(Field field) {
    if (field != null) {
      return {
        'minInterval': field.id,
        'minIntervalUnit': field.name
      };
    } else {
      return null;
    }
  }   

  List<Map<String,dynamic>> _subfieldsToJson(List<Subfield> subfields) {
    List<Map<String,dynamic>> subfieldsList = [];
    if (subfields != null) {
      for (int i = 0; i < subfields.length; i++) {
        List<Skill> skills = subfields[i].skills;
        if (skills == null) {
          skills = [];
        }
        subfieldsList.add({
          'id': subfields[i].id, 
          'name': subfields[i].name, 
          'skills': skills
        });      
      }
    }
    return subfieldsList;    
  }

  List<Map<String, dynamic>> _availabilityToJson(List<Availability> availabilities) {
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
  
  Map<String, dynamic> _timezoneToJson(TimeZoneModel timezone) {
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
        'minIntervalUnit': lessonsAvailability.minIntervalUnitToEng
      };
    } else {
      return null;
    }
  }  
}

class LessonsAvailability {
  int minInterval;
  String minIntervalUnit;

  LessonsAvailability({this.minInterval, this.minIntervalUnit}) {
    if (minIntervalUnit != null) {
      minIntervalUnit = Utils.translatePeriodUnitFromEng(minIntervalUnit);
    }
  }

  String get minIntervalUnitToEng => Utils.translatePeriodUnitToEng(minIntervalUnit);  
}