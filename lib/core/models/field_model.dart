class Field {
  String name;

  Field({this.name});

  Field.fromMap(Map snapshot) :
        name = snapshot['name'] ?? '';

  toJson() {
    return {
      'name': name
    };
  }
}