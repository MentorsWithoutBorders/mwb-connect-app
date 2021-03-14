class Tutorial {
  String id;
  List<String> sections;

  Tutorial({this.id, this.sections});

  Tutorial.fromMap(Map snapshot, String id) :
    id = id ?? '',
    sections = snapshot['sections']?.cast<String>() ?? [];

  Map<String, Object> toJson() {
    return {
      'sections': sections
    };
  }
}