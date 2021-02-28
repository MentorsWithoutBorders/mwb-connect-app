class Goal {
  String id;
  String text;
  int index;
  DateTime dateTime;

  Goal({this.id, this.text, this.index, this.dateTime});

  Goal.fromMap(Map snapshot, String id) :
    id = id,
    text = snapshot['text'] ?? '',
    index = snapshot['index'] ?? 0,
    dateTime = snapshot['dateTime']?.toDate();

  toJson() {
    return {
      'text': text,
      'index': index,
      'dateTime': dateTime
    };
  }
}