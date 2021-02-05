import 'package:mwb_connect_app/core/models/subfield_model.dart';

class Field {
  String name;
  List<Subfield> subfields;  

  Field({this.name, this.subfields});

  Field.fromMap(Map snapshot) {
    name = snapshot['name'] ?? '';
    subfields = _subfieldsFromJson(snapshot['subfields']?.cast<String>()) ?? [];
  }

  List<Subfield> _subfieldsFromJson(List<String> subfields) {
    List<Subfield> subfieldsList = [];
    for (int i = 0; i < subfields.length; i++) {
      subfieldsList.add(Subfield(name: subfields[i]));
    }
    return subfieldsList;
  }

  toJson() {
    return {
      'name': name,
      'subfields': _subfieldsToJson(subfields)
    };
  }

  List<String> _subfieldsToJson(List<Subfield> subfields) {
    List<String> subfieldsList = [];
    for (int i = 0; i < subfields.length; i++) {
      subfieldsList.add(subfields[i].name);
    }
    return subfieldsList;    
  }
}