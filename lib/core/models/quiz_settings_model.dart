class QuizSettings {
  int count;
  int rounds;
  int timeBetweenRounds;
  bool showTimer;

  QuizSettings({this.count, this.rounds, this.timeBetweenRounds, this.showTimer});

  QuizSettings.fromJson(Map<String, dynamic> json) :
    count = json['count'] ?? 0,
    rounds = json['rounds'] ?? 0,
    timeBetweenRounds = json['timeBetweenRounds'] ?? 0,
    showTimer = json['showTimer'] ?? false;

  Map<String, Object> toJson() {
    return {
      'count': count,
      'rounds': rounds,
      'timeBetweenRounds': timeBetweenRounds,
      'showTimer': showTimer
    };
  }
}