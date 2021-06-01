class StepModel {
  String id;
  String parent;
  String text;
  int level;
  int index;
  DateTime dateTime;

  StepModel({this.id, this.parent, this.text, this.level, this.index, this.dateTime});

  StepModel.fromJson(Map<String, dynamic> json) :
    id = json['id'],
    parent = json['parent'],
    text = json['text'] ?? '',
    level = json['level'] ?? 0,
    index = json['index'] ?? 0,
    dateTime = json['dateTime']?.toDate();

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