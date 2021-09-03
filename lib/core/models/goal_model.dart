class Goal {
  String? id;
  String? text;

  Goal({this.id, this.text});

  Goal.fromJson(Map<String, dynamic> json) :
    id = json['id'],
    text = json['text'] ?? '';

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'text': text
    };
  }
}