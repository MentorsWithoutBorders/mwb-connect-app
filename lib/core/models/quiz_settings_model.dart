class QuizSettings {
  int count;
  int rounds;
  int timeBetweenRounds;
  bool showTimer;

  QuizSettings({this.count, this.rounds, this.timeBetweenRounds, this.showTimer});

  QuizSettings.fromJson(Map<String, dynamic> snapshot) :
    count = snapshot['count'] ?? 0,
    rounds = snapshot['rounds'] ?? 0,
    timeBetweenRounds = snapshot['timeBetweenRounds'] ?? 0,
    showTimer = snapshot['showTimer'] ?? false;

  Map<String, Object> toJson() {
    return {
      'count': count,
      'rounds': rounds,
      'timeBetweenRounds': timeBetweenRounds,
      'showTimer': showTimer
    };
  }
}