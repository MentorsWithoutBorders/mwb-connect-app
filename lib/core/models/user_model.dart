class User {
  String id;
  String name;
  String email;

  User({this.id, this.name, this.email});

  User.fromMap(Map snapshot, String id) :
        id = id,
        name = snapshot['name'] ?? '',
        email = snapshot['email'] ?? '';

  toJson() {
    return {
      'name': name,
      'email': email
    };
  }
}