import 'package:mwb_connect_app/utils/utils.dart';

class User {
  String id;
  String name;
  String email;
  bool isMentor;
  String organization;
  String field;
  List<String> subfields;
  List<Availability> availabilities;
  bool isAvailable;
  LessonsAvailability lessonsAvailability;
  DateTime registeredOn;

  User({this.id, this.name, this.email, this.isMentor, this.organization, this.field, this.subfields, this.availabilities, this.isAvailable, this.lessonsAvailability, this.registeredOn});

  User.fromMap(Map snapshot, String id) {
    this.id = id;
    name = snapshot['name'].toString() ?? '';
    email = snapshot['email'].toString() ?? '';
    isMentor = snapshot['isMentor'] ?? false;
    organization = snapshot['organization'].toString() ?? '';
    field = snapshot['field'].toString() ?? '';
    subfields = snapshot['subfields']?.cast<String>() ?? [];
    availabilities = _availabilityFromJson(snapshot['availabilities']?.cast<Map<String,dynamic>>()) ?? [];
    isAvailable = snapshot['isAvailable'] ?? true;
    lessonsAvailability = _lessonsAvailabilityFromJson(snapshot['lessonsAvailability']) ?? LessonsAvailability();
    registeredOn = snapshot['registeredOn']?.toDate();
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
    LessonsAvailability lessonsAvailability = LessonsAvailability(maxLessons: json['maxLessons'], maxLessonsUnit: json['maxLessonsUnit'], minInterval: json['minInterval'], minIntervalUnit: json['minIntervalUnit']);
    return lessonsAvailability;
  }

  Map<String, Object> toJson() {
    return {
      'name': name,
      'email': email,
      'isMentor': isMentor,
      'organization': organization,
      'field': field,
      'subfields': subfields,
      'availabilities': _availabilityToJson(availabilities),
      'isAvailable': isAvailable,
      'lessonsAvailability': _lessonsAvailabilityToJson(lessonsAvailability),
      'registeredOn': registeredOn
    };
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
        'maxLessons': lessonsAvailability.maxLessons, 
        'maxLessonsUnit': lessonsAvailability.maxLessonsUnit, 
        'minInterval': lessonsAvailability.minInterval,
        'minIntervalUnit': lessonsAvailability.minIntervalUnit
      };
    } else {
      return Map();
    }
  }  
}

class LessonsAvailability {
  int maxLessons;
  String maxLessonsUnit;
  int minInterval;
  String minIntervalUnit;

  LessonsAvailability({this.maxLessons, this.maxLessonsUnit, this.minInterval, this.minIntervalUnit}) {
    if (maxLessonsUnit != null) {
      maxLessonsUnit = Utils.translatePeriodUnitFromEng(maxLessonsUnit);
    }
    if (minIntervalUnit != null) {
      minIntervalUnit = Utils.translatePeriodUnitFromEng(minIntervalUnit);
    }
  }

  String get maxLessonsUnitToEng => Utils.translatePeriodUnitToEng(maxLessonsUnit);  
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