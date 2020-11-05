class Tutorial {
  String id;
  String sections;

  Tutorial({this.id, this.sections});

  Tutorial.fromMap(Map snapshot, String id) :
        id = id ?? '',
        sections = snapshot['sections'] ?? '';

  toJson() {
    return {
      'sections': sections
    };
  }
}