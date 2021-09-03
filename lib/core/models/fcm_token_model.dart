class FCMToken {
  String? token;

  FCMToken({this.token});

  FCMToken.fromJson(Map<String, dynamic> json) :
    token = json['token'] ?? '';

  Map<String, Object?> toJson() {
    return {
      'token': token
    };
  }  
}