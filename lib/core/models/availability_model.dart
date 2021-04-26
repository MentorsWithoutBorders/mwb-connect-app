import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';

class Availability {
  String dayOfWeek;
  Time time;

  Availability({this.dayOfWeek, this.time}) {
    dayOfWeek = Utils.translateDayOfWeekFromEng(dayOfWeek);
  }

  String get dayOfWeekToEng => Utils.translateDayOfWeekToEng(dayOfWeek);
}