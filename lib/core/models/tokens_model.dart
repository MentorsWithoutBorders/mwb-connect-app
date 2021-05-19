class Tokens {
  String userId;
  String accessToken; 
  String refreshToken;

  Tokens({this.userId, this.accessToken, this.refreshToken});

  factory Tokens.fromJson(Map<String, dynamic> json) => Tokens(
    userId: json['userId'] != null ? json['userId'] : null,
    accessToken: json['accessToken'] != null ? json['accessToken'] : null,
    refreshToken: json['refreshToken'] != null ? json['refreshToken'] : null
  );  

  Map<String, Object> toJson() {
    return {
      'userId': userId,
      'accessToken': accessToken,
      'refreshToken': refreshToken
    };
  }
}