import 'package:mwb_connect_app/core/models/subfield_model.dart';

class Field {
  String name;
  List<Subfield> subfields;  

  Field({this.name, this.subfields});

  Field.fromMap(Map snapshot) {
    name = snapshot['name'] ?? '';
    subfields = _subfieldsFromJson(snapshot['subfields']?.cast<Map<String,dynamic>>()) ?? [];
  }

  List<Subfield> _subfieldsFromJson(List<Map<String, dynamic>> json) {
    final List<Subfield> subfieldsList = [];
    if (json != null) {
      for (int i = 0; i < json.length; i++) {
        subfieldsList.add(Subfield(name: json[i]['name'], skills: json[i]['skills']?.cast<String>()));
      }
    }
    return subfieldsList;
  }

  Map<String, Object> toJson() {
    return {
      'name': name,
      'subfields': _subfieldsToJson(subfields)
    };
  }

  List<Map<String,dynamic>> _subfieldsToJson(List<Subfield> subfields) {
    List<Map<String,dynamic>> subfieldsList = [];
    if (subfields != null) {
      for (int i = 0; i < subfields.length; i++) {
        subfieldsList.add({
          'name': subfields[i].name, 
          'skills': subfields[i].skills
        });      
      }
    }
    return subfieldsList;    
  }
}