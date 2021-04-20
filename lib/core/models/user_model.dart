import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';

class User {
  String id;
  String name;
  String email;
  bool isMentor;
  String organization;
  String field;
  List<Subfield> subfields;
  List<Availability> availabilities;
  bool isAvailable;
  DateTime availableFrom;
  LessonsAvailability lessonsAvailability;
  DateTime registeredOn;

  User({this.id, this.name, this.email, this.isMentor, this.organization, this.field, this.subfields, this.availabilities, this.isAvailable, this.availableFrom, this.lessonsAvailability, this.registeredOn});

  User.fromMap(Map snapshot, String id) {
    this.id = id;
    name = snapshot['name'].toString() ?? '';
    email = snapshot['email'].toString() ?? '';
    isMentor = snapshot['isMentor'] ?? false;
    organization = snapshot['organization'].toString() ?? '';
    field = snapshot['field'].toString() ?? '';
    subfields = subfieldsFromJson(snapshot['subfields']?.cast<Map<String,dynamic>>()) ?? [];
    availabilities = _availabilityFromJson(snapshot['availabilities']?.cast<Map<String,dynamic>>()) ?? [];
    isAvailable = snapshot['isAvailable'] ?? true;
    availableFrom = snapshot['availableFrom']?.toDate();
    lessonsAvailability = _lessonsAvailabilityFromJson(snapshot['lessonsAvailability']) ?? null;
    registeredOn = snapshot['registeredOn']?.toDate();
  }

  List<Subfield> subfieldsFromJson(List<Map<String, dynamic>> json) {
    final List<Subfield> subfieldsList = [];
    if (json != null) {
      for (int i = 0; i < json.length; i++) {
        subfieldsList.add(Subfield(name: json[i]['name'], skills: json[i]['skills']?.cast<String>()));
      }
    }
    return subfieldsList;
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
      'name': name,
      'email': email,
      'isMentor': isMentor,
      'organization': organization,
      'field': field,
      'subfields': _subfieldsToJson(subfields),
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

  List<Map<String,dynamic>> _subfieldsToJson(List<Subfield> subfields) {
    List<Map<String,dynamic>> subfieldsList = [];
    if (subfields != null) {
      for (int i = 0; i < subfields.length; i++) {
        List<String> skills = subfields[i].skills;
        if (skills == null) {
          skills = [];
        }
        subfieldsList.add({
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

class Availability {
  String dayOfWeek;
  Time time;

  Availability({this.dayOfWeek, this.time}) {
    dayOfWeek = Utils.translateDayOfWeekFromEng(dayOfWeek);
  }

  String get dayOfWeekToEng => Utils.translateDayOfWeekToEng(dayOfWeek);
}

class Time {
  String from;
  String to;

  Time({this.from, this.to});
}