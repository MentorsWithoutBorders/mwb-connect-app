class User {
  String id;
  String name;
  String email;
  bool isMentor;
  String organization;
  String field;
  List<String> subFields;
  List<Availability> availability;
  bool isAvailable;
  LessonsAvailability lessonsAvailability;
  DateTime registeredOn;

  User({this.id, this.name, this.email, this.isMentor, this.organization, this.field, this.subFields, this.availability, this.isAvailable, this.lessonsAvailability, this.registeredOn});

  User.fromMap(Map snapshot, String id) {
    this.id = id;
    name = snapshot['name'] ?? '';
    email = snapshot['email'] ?? '';
    isMentor = snapshot['isMentor'] ?? false;
    organization = snapshot['organization'] ?? '';
    field = snapshot['field'] ?? '';
    subFields = snapshot['subFields']?.cast<String>() ?? [];
    availability = availabilityFromJson(snapshot['availability']?.cast<Map<String,dynamic>>()) ?? [];
    isAvailable = snapshot['isAvailable'] ?? true;
    lessonsAvailability = lessonsAvailabilityFromJson(snapshot['lessonsAvailability']) ?? LessonsAvailability();
    registeredOn = snapshot['registeredOn']?.toDate();
  }
  
  List<Availability> availabilityFromJson(List<Map<String, dynamic>> json) {
    List<Availability> availabilityList = List();
    if (json != null) {
      for (int i = 0; i < json.length; i++) {
        availabilityList.add(Availability(dayOfWeek: json[i]['dayOfWeek'], time: Time(from: json[i]['time']['from'], to: json[i]['time']['to'])));
      }
    }
    return availabilityList;
  }

  LessonsAvailability lessonsAvailabilityFromJson(Map<String, dynamic> json) {
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
      'subFields': subFields,
      'availability': availabilityToJson(availability),
      'isAvailable': isAvailable,
      'lessonsAvailability': lessonsAvailabilityToJson(lessonsAvailability),
      'registeredOn': registeredOn
    };
  }

  List<Map<String, dynamic>> availabilityToJson(List<Availability> availability) {
    List<Map<String,dynamic>> availabilityList = List();
    if (availability != null) {
      for (int i = 0; i < availability.length; i++) {
        availabilityList.add({
          'dayOfWeek': availability[i].dayOfWeek, 
          'time': {
            'from': availability[i].time.from,
            'to': availability[i].time.to
          }
        });
      }
    }
    return availabilityList;
  }   

  Map<String, dynamic> lessonsAvailabilityToJson(LessonsAvailability lessonsAvailability) {
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