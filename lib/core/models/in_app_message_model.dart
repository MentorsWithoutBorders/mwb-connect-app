class InAppMessage {
  String? text;

  InAppMessage({this.text});

  InAppMessage.fromJson(Map<String, dynamic> json) :
    text = json['text'] ?? '';

  Map<String, Object?> toJson() {
    return {
      'text': text
    };
  }  
}