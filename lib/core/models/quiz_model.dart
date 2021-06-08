class Quiz {
  int number;
  bool isCorrect;
  bool isClosed;

  Quiz({this.number, this.isCorrect, this.isClosed});

  Quiz.fromJson(Map<String, dynamic> snapshot) :
    number = snapshot['number'],
    isCorrect = snapshot['isCorrect'] ?? null,
    isClosed = snapshot['isClosed'] ?? null;

  Map<String, Object> toJson() {
    return {
      'number': number,
      'isCorrect': isCorrect,
      'isClosed': isClosed
    };
  }
}