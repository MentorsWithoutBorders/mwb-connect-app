class SupportRequest {
  String? text; 

  SupportRequest({this.text});

  SupportRequest.fromJson(Map<String, dynamic> json) :
    text = json['text'] ?? '';

  Map<String, Object?> toJson() {
    return {
      'text': text
    };
  }
}