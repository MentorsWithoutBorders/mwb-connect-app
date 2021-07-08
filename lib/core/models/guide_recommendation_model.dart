class GuideRecommendation {
  String type;
  List<String> recommendations;

  GuideRecommendation({this.type, this.recommendations});

  GuideRecommendation.fromJson(Map<String, dynamic> json) {
    type = json['type'] ?? '';
    recommendations = json['recommendations']?.cast<String>() ?? [];
  }

  Map<String, Object> toJson() {
    return {
      'type': type,
      'recommendations': recommendations
    };
  }
}