class QuizSettings {
  int studentWeeklyCount;
  int mentorWeeklyCount;

  QuizSettings({this.studentWeeklyCount, this.mentorWeeklyCount});

  QuizSettings.fromJson(Map<String, dynamic> json) :
    studentWeeklyCount = json['studentWeeklyCount'],
    mentorWeeklyCount = json['mentorWeeklyCount'];

  Map<String, Object> toJson() {
    return {
      'studentWeeklyCount': studentWeeklyCount,
      'mentorWeeklyCount': mentorWeeklyCount
    };
  }
}