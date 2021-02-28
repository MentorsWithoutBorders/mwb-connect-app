class QuizSettings {
  String id;
  int count;
  int rounds;
  int timeBetweenRounds;
  bool showTimer;

  QuizSettings({this.id, this.count, this.rounds, this.timeBetweenRounds, this.showTimer});

  QuizSettings.fromMap(Map snapshot, String id) :
    id = id,
    count = snapshot['count'] ?? 0,
    rounds = snapshot['rounds'] ?? 0,
    timeBetweenRounds = snapshot['timeBetweenRounds'] ?? 0,
    showTimer = snapshot['showTimer'] ?? false;

  toJson() {
    return {
      'count': count,
      'rounds': rounds,
      'timeBetweenRounds': timeBetweenRounds,
      'showTimer': showTimer
    };
  }
}