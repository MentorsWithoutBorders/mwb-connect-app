import 'package:mwb_connect_app/core/models/user_model.dart';

class ApprovedUser extends User {
  String goal;

  ApprovedUser({id, name, email, isMentor, organization, field, subfields, goal}) : 
    super(id: id, name: name, email: email, isMentor: isMentor, organization: organization, field: field, subfields: subfields);

  ApprovedUser.fromMap(Map snapshot, String id) {
    this.id = id;
    name = snapshot['name'] ?? '';
    email = snapshot['email'] ?? '';
    isMentor = snapshot['isMentor'] ?? false;
    organization = snapshot['organization'] ?? '';
    field = snapshot['field'] ?? '';
    subfields = snapshot['subfields']?.cast<String>() ?? [];
    goal = snapshot['goal'] ?? '';
  }

  toJson() {
    return {
      'name': name,
      'email': email,
      'isMentor': isMentor,
      'organization': organization,
      'field': field,
      'subfields': subfields,
      'goal': goal
    };
  }    
}