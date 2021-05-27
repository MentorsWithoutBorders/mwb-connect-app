import 'package:mwb_connect_app/core/models/skill_model.dart';

class Subfield {
  String id;
  String name;
  List<Skill> skills;

  Subfield({this.id, this.name, this.skills});

  Subfield.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    skills = _skillsFromJson(json['skills']?.cast<Map<String,dynamic>>()) ?? [];
  }

  List<Skill> _skillsFromJson(List<Map<String, dynamic>> json) {
    final List<Skill> skillsList = [];
    if (json != null) {
      for (int i = 0; i < json.length; i++) {
        skillsList.add(Skill(id: json[i]['id'], name: json[i]['name']));
      }
    }
    return skillsList;
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'skills': _skillsToJson(skills)
    };
  }

  List<Map<String,dynamic>> _skillsToJson(List<Skill> skills) {
    List<Map<String,dynamic>> skillsList = [];
    if (skills != null) {
      for (int i = 0; i < skills.length; i++) {
        skillsList.add({
          'id': skills[i].name, 
          'name': skills[i].name
        });      
      }
    }
    return skillsList;    
  }  
}