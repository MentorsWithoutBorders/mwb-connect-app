class QuizStatus {
  String id;
  String solved;
  DateTime lastSolved;
  int roundsSolved;

  QuizStatus({this.id, this.solved, this.lastSolved, this.roundsSolved});

  QuizStatus.fromMap(Map snapshot, String id) :
    id = id,
    solved = snapshot['solved'] ?? '',
    lastSolved = snapshot['lastSolved']?.toDate(),
    roundsSolved = snapshot['roundsSolved'] ?? 0;

  Map<String, Object> toJson() {
    return {
      'solved': solved,
      'lastSolved': lastSolved,
      'roundsSolved': roundsSolved
    };
  }
}