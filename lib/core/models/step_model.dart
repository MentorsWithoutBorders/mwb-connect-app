class StepModel {
  String id;
  String parent;
  String text;
  int level;
  int index;
  DateTime dateTime;

  StepModel({this.id, this.parent, this.text, this.level, this.index, this.dateTime});

  StepModel.fromMap(Map snapshot, String id) :
    id = id,
    parent = snapshot['parent'],
    text = snapshot['text'] ?? '',
    level = snapshot['level'] ?? 0,
    index = snapshot['index'] ?? 0,
    dateTime = snapshot['dateTime']?.toDate();

  Map<String, Object> toJson() {
    return {
      'parent': parent,
      'text': text,
      'level': level,
      'index': index,
      'dateTime': dateTime
    };
  }
}