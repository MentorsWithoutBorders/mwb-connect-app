class Organization {
  String id;
  String name;

  Organization({this.id, this.name});

  Organization.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name
    };
  }
}