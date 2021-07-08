class GuideTutorial {
  List<String> skills;
  List<String> tutorialUrls;

  GuideTutorial({this.skills, this.tutorialUrls});

  GuideTutorial.fromJson(Map<String, dynamic> json) {
    skills = json['skills']?.cast<String>() ?? [];
    tutorialUrls = json['tutorialUrls']?.cast<String>() ?? [];
  }

  Map<String, Object> toJson() {
    return {
      'skills': skills,
      'tutorialUrls': tutorialUrls
    };
  }
}