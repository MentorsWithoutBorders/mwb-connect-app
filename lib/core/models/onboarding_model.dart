class Onboarding {
  String id;
  String sections;

  Onboarding({this.id, this.sections});

  Onboarding.fromMap(Map snapshot, String id) :
        id = id ?? '',
        sections = snapshot['sections'] ?? '';

  toJson() {
    return {
      'sections': sections
    };
  }
}