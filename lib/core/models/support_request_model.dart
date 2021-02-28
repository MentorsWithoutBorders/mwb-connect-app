class SupportRequest {
  String id;
  String text; 
  String userId;
  String userName;
  String userEmail;
  DateTime dateTime;

  SupportRequest({this.id, this.text, this.userId, this.userName, this.userEmail, this.dateTime});

  SupportRequest.fromMap(Map snapshot, String id) :
    id = id,
    text = snapshot['text'] ?? '',
    userId = snapshot['userId'] ?? '',
    userName = snapshot['userName'] ?? '',
    userEmail = snapshot['userEmail'] ?? '';

  toJson() {
    return {
      'text': text,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'dateTime': dateTime
    };
  }
}