class LessonRequestResult {
  String? id;
  bool? isLessonRequest;

  LessonRequestResult({this.id, this.isLessonRequest});

  LessonRequestResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isLessonRequest = json['isLessonRequest'];
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'isLessonRequest': isLessonRequest
    };
  }
}