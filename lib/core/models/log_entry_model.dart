class LogEntry {
  String? text;

  LogEntry({this.text});

  LogEntry.fromJson(Map<String, dynamic> json) :
    text = json['text'] ?? '';

  Map<String, Object?> toJson() {
    return {
      'text': text
    };
  }
}