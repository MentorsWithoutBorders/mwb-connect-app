class Quiz {
  String id;
  int number;
  String status;
  DateTime dateTime;

  Quiz({this.id, this.number, this.status, this.dateTime});

  Quiz.fromMap(Map snapshot, String id) :
    id = id,
    number = snapshot['number'],
    status = snapshot['status'] ?? '',
    dateTime = snapshot['dateTime']?.toDate();

  Map<String, Object> toJson() {
    return {
      'number': number,
      'status': status,
      'dateTime': dateTime
    };
  }
}