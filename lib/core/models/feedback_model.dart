class FeedbackModel {
  String id;
  String text; 
  String userId;
  String userName;
  String userEmail;
  DateTime dateTime;

  FeedbackModel({this.id, this.text, this.userId, this.userName, this.userEmail, this.dateTime});

  FeedbackModel.fromMap(Map snapshot, String id) :
    id = id,
    text = snapshot['text'] ?? '',
    userId = snapshot['userId'] ?? '',
    userName = snapshot['userName'] ?? '',
    userEmail = snapshot['userEmail'] ?? '';

  Map<String, Object> toJson() {
    return {
      'text': text,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'dateTime': dateTime
    };
  }
}