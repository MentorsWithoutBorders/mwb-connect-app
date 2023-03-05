class AttachedMessage {
  String? text;

  AttachedMessage({this.text});

  AttachedMessage.fromJson(Map<String, dynamic> json) :
    text = json['text'] ?? '';

  Map<String, Object?> toJson() {
    return {
      'text': text
    };
  }  
}