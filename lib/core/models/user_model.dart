import 'package:mwb_connect_app/core/models/lessons_availability_model.dart';

class User {
  String id;
  String name;
  String email;
  bool isMentor;
  String organization;
  String field;
  List<String> subFields;
  List<String> availability;
  bool isAvailable;
  LessonsAvailability lessonsAvailability;
  DateTime registeredOn;

  User({this.id, this.name, this.email, this.isMentor, this.organization, this.field, this.subFields, this.availability, this.isAvailable, this.lessonsAvailability, this.registeredOn});

  User.fromMap(Map snapshot, String id) {
    id = id;
    name = snapshot['name'] ?? '';
    email = snapshot['email'] ?? '';
    isMentor = snapshot['isMentor'] ?? false;
    organization = snapshot['organization'] ?? '';
    field = snapshot['field'] ?? '';
    subFields = snapshot['subFields']?.cast<String>() ?? [];
    availability = snapshot['availability']?.cast<String>() ?? [];
    isAvailable = snapshot['isAvailable'] ?? true;
    lessonsAvailability = lessonsAvailabilityFromJson(snapshot['lessonsAvailability']) ?? LessonsAvailability();
    registeredOn = snapshot['registeredOn']?.toDate();
  } 

  LessonsAvailability lessonsAvailabilityFromJson(Map<String, dynamic> json) {
    return LessonsAvailability(maxNumber: json['maxNumber'], maxNumberUnit: json['maxNumberUnit'], minInterval: json['minInterval'], minIntervalUnit: json['minIntervalUnit']);
  }

  toJson() {
    return {
      'name': name,
      'email': email,
      'isMentor': isMentor,
      'organization': organization,
      'field': field,
      'subFields': subFields,
      'availability': availability,
      'isAvailable': isAvailable,
      'lessonsAvailability': lessonsAvailabilityToJson(lessonsAvailability),
      'registeredOn': registeredOn
    };
  }

  Map<String, dynamic> lessonsAvailabilityToJson(LessonsAvailability availability) {
    return {
      'maxNumber': availability.maxNumber, 
      'maxNumberUnit': availability.maxNumberUnit, 
      'minInterval': availability.minInterval,
      'minIntervalUnit': availability.minIntervalUnit
    };
  }  
}