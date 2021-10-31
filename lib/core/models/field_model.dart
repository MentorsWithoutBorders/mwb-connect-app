import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';

class Field {
  String? id;
  String? name;
  List<Subfield>? subfields;  

  Field({this.id, this.name, this.subfields});

  Field.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    subfields = _subfieldsFromJson(json['subfields']?.cast<Map<String,dynamic>>());
  }

  List<Subfield> _subfieldsFromJson(List<Map<String, dynamic>> json) {
    final List<Subfield> subfieldsList = [];
    for (int i = 0; i < json.length; i++) {
      subfieldsList.add(Subfield.fromJson(json[i]));
    }
    return subfieldsList;
  }

  Map<String, Object?> toJson() {
    return {
      'id': id ,
      'name': name,
      'subfields': _subfieldsToJson(subfields)
    };
  }

  List<Map<String,dynamic>> _subfieldsToJson(List<Subfield>? subfields) {
    List<Map<String,dynamic>> subfieldsList = [];
    if (subfields != null) {
      for (int i = 0; i < subfields.length; i++) {
        subfieldsList.add({
          'id': subfields[i].id, 
          'name': subfields[i].name, 
          'skills': _skillsToJson(subfields[i].skills)
        });      
      }
    }
    return subfieldsList;    
  }

  List<Map<String,dynamic>> _skillsToJson(List<Skill>? skills) {
    List<Map<String,dynamic>> skillsList = [];
    if (skills != null) {
      for (int i = 0; i < skills.length; i++) {
        skillsList.add(skills[i].toJson());      
      }
    }
    return skillsList;    
  }

}