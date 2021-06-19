import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/constants.dart';

// ignore: avoid_classes_with_only_static_members
class Utils {
  static List<String> get daysOfWeek => 'common.days_of_week'.tr().split(', ');
  static List<String> get periodUnits => 'common.period_units'.tr().split(', ');
  
  static List<String> getPeriodUnitsPlural() {
    List<String> periodUnitsPlural = [];
    for (final String periodUnit in Utils.periodUnits) {
      periodUnitsPlural.add(plural(periodUnit, 2));
    }
    return periodUnitsPlural;
  }    

  static String translateDayOfWeekToEng(String dayOfWeek) {
    return AppConstants.daysOfWeekEng[daysOfWeek.indexOf(dayOfWeek)];
  }

  static String translateDayOfWeekFromEng(String dayOfWeek) {
    return daysOfWeek[AppConstants.daysOfWeekEng.indexOf(dayOfWeek)];
  }

  static String translatePeriodUnitToEng(String periodUnit) {
    return AppConstants.periodUnitsEng[periodUnits.indexOf(periodUnit)];
  }

  static String translatePeriodUnitFromEng(String periodUnit) {
    return periodUnits[AppConstants.periodUnitsEng.indexOf(periodUnit)];
  }   

  static int convertTime12to24(String time12h) {
    int hours = int.parse(time12h.replaceAll(RegExp(r'[^0-9]'),''));
    final String modifier = time12h.replaceAll(hours.toString(), '');
    if (hours == 12) {
      hours = 0;
    }
    if (modifier == 'pm') {
      hours = hours + 12;
    }
    return hours;
  }

  static List<String> buildHoursList() {
    final List<String> hoursList = [];
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

  static DateTime resetTime(DateTime dateTime) {
    return dateTime.subtract(Duration(hours: dateTime.hour, minutes: dateTime.minute, seconds: dateTime.second, milliseconds: dateTime.millisecond, microseconds: dateTime.microsecond));
  }
  
  static String getUrlType(String url) {
    if (url.contains('meet')) {
      return 'Google Meet';
    } else if (url.contains('zoom')) {
      return 'Zoom';
    } else {
      return '';
    }
  }
}