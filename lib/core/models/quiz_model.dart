class Quiz {
  int? number;
  bool? isCorrect;
  bool? isClosed;

  Quiz({this.number, this.isCorrect, this.isClosed});

  Quiz.fromJson(Map<String, dynamic> json) :
    number = json['number'],
    isCorrect = json['isCorrect'],
    isClosed = json['isClosed'];

  Map<String, Object?> toJson() {
    return {
      'number': number,
      'isCorrect': isCorrect,
      'isClosed': isClosed
    };
  }
}