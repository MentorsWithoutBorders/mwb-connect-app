import 'package:mwb_connect_app/core/models/step_model.dart';

class Goal {
  String id;
  String text;
  List<StepModel> steps;

  Goal({this.id, this.text});

  Goal.fromJson(Map<String, dynamic> json) :
    id = json['id'] ?? '',
    text = json['text'] ?? '';

  Map<String, Object> toJson() {
    return {
      'id': id,
      'text': text
    };
  }
}