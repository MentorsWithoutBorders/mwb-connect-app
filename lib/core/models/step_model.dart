class StepModel {
  String id;
  String parentId;
  String text;
  int level;
  int index;

  StepModel({this.id, this.parentId, this.text, this.level, this.index});

  StepModel.fromJson(Map<String, dynamic> json) :
    id = json['id'],
    parentId = json['parentId'],
    text = json['text'] ?? '',
    level = json['level'] ?? 0,
    index = json['index'] ?? 0;

  Map<String, Object> toJson() {
    return {
      'parentId': parentId,
      'text': text,
      'level': level,
      'index': index
    };
  }
}