class LessonRecurrenceResult {
  String? id;
  int? studentsRemaining;

  LessonRecurrenceResult({this.id, this.studentsRemaining});

  LessonRecurrenceResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    studentsRemaining = json['studentsRemaining'];
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'studentsRemaining': studentsRemaining
    };
  }
}