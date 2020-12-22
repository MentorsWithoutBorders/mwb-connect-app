class User {
  String id;
  String name;
  String email;
  bool isMentor;
  String organization;
  String field;
  List<String> subFields;

  User({this.id, this.name, this.email, this.isMentor, this.organization, this.field, this.subFields});

  User.fromMap(Map snapshot, String id) :
        id = id,
        name = snapshot['name'] ?? '',
        email = snapshot['email'] ?? '',
        isMentor = snapshot['isMentor'] ?? false,
        organization = snapshot['organization'] ?? '',
        field = snapshot['field'] ?? '',
        subFields = snapshot['subFields'] ?? [];

  toJson() {
    return {
      'name': name,
      'email': email,
      'isMentor': isMentor,
      'organization': organization,
      'field': field,
      'subFields': subFields
    };
  }
}