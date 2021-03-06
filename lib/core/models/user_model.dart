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
    name = snapshot['name'] ?? '';
    email = snapshot['email'] ?? '';
    isMentor = snapshot['isMentor'] ?? false;
    organization = snapshot['organization'] ?? '';
    field = snapshot['field'] ?? '';
    subfields = snapshot['subfields']?.cast<String>() ?? [];
    availabilities = _availabilityFromJson(snapshot['availabilities']?.cast<Map<String,dynamic>>()) ?? [];
    isAvailable = snapshot['isAvailable'] ?? true;
    lessonsAvailability = _lessonsAvailabilityFromJson(snapshot['lessonsAvailability']) ?? LessonsAvailability();
    registeredOn = snapshot['registeredOn']?.toDate();
  }
  
  List<Availability> _availabilityFromJson(List<Map<String, dynamic>> json) {
    List<Availability> availabilityList = List();
    if (json != null) {
      for (int i = 0; i < json.length; i++) {
        availabilityList.add(Availability(dayOfWeek: json[i]['dayOfWeek'], time: Time(from: json[i]['time']['from'], to: json[i]['time']['to'])));
      }
    }
    return availabilityList;
  }

  LessonsAvailability _lessonsAvailabilityFromJson(Map<String, dynamic> json) {
    LessonsAvailability lessonsAvailability = LessonsAvailability();
    if (json != null) {
      lessonsAvailability = LessonsAvailability(maxNumber: json['maxNumber'], maxNumberUnit: json['maxNumberUnit'], minInterval: json['minInterval'], minIntervalUnit: json['minIntervalUnit']);
    }
    return lessonsAvailability;
  }

  toJson() {
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
    List<Map<String,dynamic>> availabilityList = List();
    if (availabilities != null) {
      for (int i = 0; i < availabilities.length; i++) {
        availabilityList.add({
          'dayOfWeek': availabilities[i].dayOfWeek, 
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
        'maxNumber': lessonsAvailability.maxNumber, 
        'maxNumberUnit': lessonsAvailability.maxNumberUnit, 
        'minInterval': lessonsAvailability.minInterval,
        'minIntervalUnit': lessonsAvailability.minIntervalUnit
      };
    } else {
      return Map();
    }
  }  
}

class LessonsAvailability {
  int maxNumber;
  String maxNumberUnit;
  int minInterval;
  String minIntervalUnit;

  LessonsAvailability({this.maxNumber, this.maxNumberUnit, this.minInterval, this.minIntervalUnit});
}

class Availability {
  String dayOfWeek;
  Time time;

  Availability({this.dayOfWeek, this.time});
}

class Time {
  String from;
  String to;

  Time({this.from, this.to});
}