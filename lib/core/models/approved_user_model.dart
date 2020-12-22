import 'package:mwb_connect_app/core/models/user_model.dart';

class ApprovedUser extends User {
  String goal;

  ApprovedUser({id, name, email, isMentor, organization, field, subFields, goal}) : 
    super(id: id, name: name, email: email, isMentor: isMentor, organization: organization, field: field, subFields: subFields);

  ApprovedUser.fromMap(Map snapshot, String id) {
    id = id;
    name = snapshot['name'] ?? '';
    email = snapshot['email'] ?? '';
    isMentor = snapshot['isMentor'] ?? false;
    organization = snapshot['organization'] ?? '';
    field = snapshot['field'] ?? '';
    subFields = snapshot['subFields'] ?? [];
    goal = snapshot['goal'] ?? '';
  }

  toJson() {
    return {
      'name': name,
      'email': email,
      'isMentor': isMentor,
      'organization': organization,
      'field': field,
      'subFields': subFields,
      'goal': goal
    };
  }    
}