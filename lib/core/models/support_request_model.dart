class SupportRequest {
  String text; 

  SupportRequest({this.text});

  SupportRequest.fromJson(Map<String, dynamic> snapshot) :
    text = snapshot['text'] ?? '';

  Map<String, Object> toJson() {
    return {
      'text': text
    };
  }
}