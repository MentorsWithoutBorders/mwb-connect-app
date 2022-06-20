import 'package:easy_localization/easy_localization.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

// ignore: avoid_classes_with_only_static_members
class Utils {
  static final LocalStorageService _storageService = locator<LocalStorageService>();  

  static List<String> get daysOfWeek => 'common.days_of_week'.tr().split(', ');

  static String translateDayOfWeekToEng(String dayOfWeek) {
    return AppConstants.daysOfWeekEng[daysOfWeek.indexOf(dayOfWeek)];
  }

  static String translateDayOfWeekFromEng(String dayOfWeek) {
    return daysOfWeek[AppConstants.daysOfWeekEng.indexOf(dayOfWeek)];
  }

  static List<int> convertTime12to24(String time12h) {
    String time = time12h.replaceAll(RegExp(r'[^0-9:]'), '');
    if (!time12h.contains(':')) {
      time = time12h.replaceAll(RegExp(r'[^0-9]'), '');
    }
    final String modifier = time12h.replaceAll(time, '').toLowerCase();
    int hours = int.parse(time.split(':')[0]);
    int minutes = time12h.contains(':') ? int.parse(time.split(':')[1]) : 0;
    if (hours == 12) {
      hours = 0;
    }
    if (modifier == 'pm') {
      hours = hours + 12;
    }
    return [hours, minutes];
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

  static bool checkValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
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

  static DateTime? getNextDeadline() {
    Jiffy now = Jiffy(resetTime(DateTime.now()));
    Jiffy deadline = Jiffy(resetTime(DateTime.parse(_storageService.registeredOn as String)));
    if (deadline.isSame(now)) {
      deadline.add(weeks: 1);
      deadline = Jiffy(getDSTAdjustedDateTime(deadline.dateTime));
    } else {
      while (deadline.isBefore(now, Units.DAY)) {
        deadline.add(weeks: 1);
        deadline = Jiffy(getDSTAdjustedDateTime(deadline.dateTime));
      }
    }
    return deadline.dateTime;
  }

  static DateTime getDSTAdjustedDateTime(DateTime dateTime) {
    if (dateTime.hour == 23) {
      dateTime = dateTime.subtract(Duration(hours: 23));
      dateTime = dateTime.add(Duration(days: 1));
    } else if (dateTime.hour == 1) {
      dateTime = dateTime.subtract(Duration(hours: 1));
    }
    return dateTime;
  }

  static int getDSTAdjustedDifferenceInDays(DateTime dateTime1, DateTime dateTime2) {
    int differenceInHours = dateTime1.difference(dateTime2).inHours;
    int differenceInDays = dateTime1.difference(dateTime2).inDays;
    if (differenceInHours % 24 == 23) {
      differenceInDays += 1;
    }
    return differenceInDays;
  }  

  static String getTrainingWeek() {
    int weekNumber = getTrainingWeekNumber();
    String week = '';
    switch (weekNumber) {
      case 1:
        week = 'numerals.first'.tr();
        break;
      case 2: 
        week = 'numerals.second'.tr();
        break;
      case 3: 
        week = 'numerals.third'.tr();
        break;
      default:
        week = 'numerals.nth'.tr(args: [weekNumber.toString()]);
    }
    return week;
  }

  static int getTrainingWeekNumber() {
    Jiffy nextDeadline = Jiffy(getNextDeadline());
    Jiffy dateFromRegisteredOn = Jiffy(resetTime(DateTime.parse(_storageService.registeredOn as String)));
    int weekNumber = 0;
    while (dateFromRegisteredOn.isSameOrBefore(nextDeadline, Units.DAY)) {
      dateFromRegisteredOn.add(weeks: 1);
      dateFromRegisteredOn = Jiffy(getDSTAdjustedDateTime(dateFromRegisteredOn.dateTime));
      weekNumber++;
    }
    weekNumber--;
    return weekNumber;
  }
  
  static String getNextDayOfWeek(String dayOfWeek) {
    for (int i = 0; i < daysOfWeek.length; i++) {
      if (dayOfWeek == daysOfWeek[i]) {
        if (i == daysOfWeek.length - 1) {
          return daysOfWeek[0];
        } else {
          return daysOfWeek[i+1];
        }
      }
    }
    return dayOfWeek;
  }

  static DateTime setDayOfWeek(DateTime dateTime, String newDayOfWeek) {
    String dayOfWeek = DateFormat(AppConstants.dayOfWeekFormat, 'en').format(dateTime);
    while (dayOfWeek != newDayOfWeek) {
      dateTime.add(Duration(days: 1));
    }
    return dateTime;
  }  
  
  static String getIndefiniteArticle(String noun) {
    String article = 'common.a'.tr();
    if (AppConstants.vowels.contains(noun[0])) {
      article = 'common.an'.tr();
    }
    return article;
  }

  static bool isLessonRecurrent(DateTime lessonDateTime, DateTime? endRecurrenceDateTime) {
    DateFormat dateTimeFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
    return endRecurrenceDateTime != null && dateTimeFormat.format(lessonDateTime) != dateTimeFormat.format(endRecurrenceDateTime);
  }

  static String setUrl(String url) {
    if (url.isNotEmpty && url.indexOf('http') == -1) {
      return 'https://' + url;
    }
    return url.replaceFirst('http://', 'https://');
  }
}