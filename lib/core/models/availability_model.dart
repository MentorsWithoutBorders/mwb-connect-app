import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';

class Availability {
  String dayOfWeek;
  Time time;

  Availability({this.dayOfWeek, this.time});

  Availability.fromJson(Map<String, dynamic> json) {
    dayOfWeek = json['dayOfWeek'] != null ? Utils.translateDayOfWeekFromEng(json['dayOfWeek']) : '';
    time = _timeFromJson(json['time']);
  }

  Time _timeFromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }
    Time time = Time.fromJson(json);
    return time;
  }    

  Map<String, Object> toJson() {
    return {
      'dayOfWeek': Utils.translateDayOfWeekToEng(dayOfWeek),
      'time': time?.toJson()
    };
  }
}