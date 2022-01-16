class FieldGoal {
  String? fieldId;
  String? whyChooseUrl;

  FieldGoal({this.fieldId, this.whyChooseUrl});

  FieldGoal.fromJson(Map<String, dynamic> json) {
    fieldId = json['fieldId'] ?? '';
    whyChooseUrl = json['whyChooseUrl'] ?? '';
  }

  Map<String, Object?> toJson() {
    return {
      'fieldId': fieldId,
      'whyChooseUrl': whyChooseUrl
    };
  }
}