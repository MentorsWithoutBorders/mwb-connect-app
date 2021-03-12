import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/constants.dart';

class Utils {
  static List<String> get daysOfWeek => 'common.days_of_week'.tr().split(', ');  

  static String translateDayOfWeekToEng(String dayOfWeek) {
    return AppConstants.daysOfWeekEng[daysOfWeek.indexOf(dayOfWeek)];
  }

  static String translateDayOfWeekFromEng(String dayOfWeek) {
    return daysOfWeek[AppConstants.daysOfWeekEng.indexOf(dayOfWeek)];
  }  

  static int convertTime12to24(String time12h) {
    int hours = int.parse(time12h.replaceAll(RegExp(r'[^0-9]'),''));
    String modifier = time12h.replaceAll(hours.toString(), '');
    if (hours == 12) {
      hours = 0;
    }
    if (modifier == 'pm') {
      hours = hours + 12;
    }
    return hours;
  }

  static List<String> buildHoursList() {
    List<String> hoursList = [];
    hoursList.add('12am');
    for (int i = 1; i <= 11; i++) {
      hoursList.add(i.toString() + 'am');
    }
    hoursList.add('12pm');
    for (int i = 1; i <= 11; i++) {
      hoursList.add(i.toString() + 'pm');
    }    
    return hoursList;
  }
}