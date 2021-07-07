class Tutorial {
  String type;
  List<String> sections;

  Tutorial({this.type, this.sections});

  Tutorial.fromJson(Map<String, dynamic> json) :
    type = json['type'] ?? '',
    sections = json['sections']?.cast<String>() ?? [];

  Map<String, Object> toJson() {
    return {
      'type': type,
      'sections': sections
    };
  }
}