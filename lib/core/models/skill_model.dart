class Skill {
  String? id;
  String? name;

  Skill({this.id, this.name});

  Skill.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name
    };
  }
}