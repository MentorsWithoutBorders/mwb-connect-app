import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/datetime_extension.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

// ignore: avoid_classes_with_only_static_members
class Utils {
  static final String _defaultLocale = Platform.localeName;
  static final LocalStorageService _storageService = locator<LocalStorageService>();  
  static bool _mergedAvailabilityLastShown = false;  

  static List<String> get daysOfWeek => 'common.days_of_week'.tr().split(', ');
  static List<String> get periodUnits => 'common.period_units'.tr().split(', ');
  
  static List<String> getPeriodUnitsPlural() {
    List<String> periodUnitsPlural = [];
    for (final String periodUnit in periodUnits) {
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

  static List<int> convertTime12to24(String time12h) {
    String time = time12h.replaceAll(RegExp(r'[^0-9:]'), '');
    if (!time12h.contains(':')) {
      time = time12h.replaceAll(RegExp(r'[^0-9]'), '');
    }
    final String modifier = time12h.replaceAll(time, '');
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

  static Availability getAvailabilityToUtc(Availability availability) {
    DateFormat dayOfWeekFormat = DateFormat('EEEE');
    DateFormat timeFormat = DateFormat('h:mma');
    DateTime date = resetTime(DateTime.now());
    while (dayOfWeekFormat.format(date) != availability.dayOfWeek) {
      date = getDSTAdjustedDateTime(date.add(Duration(days: 1)));
    }
    List<int> availabilityTimeFrom = convertTime12to24(availability.time?.from as String);
    List<int> availabilityTimeTo = convertTime12to24(availability.time?.to as String);
    final DateTime timeFrom = date.copyWith(hour: availabilityTimeFrom[0], minute: availabilityTimeFrom[1]).toUtc();
    final DateTime timeTo = date.copyWith(hour: availabilityTimeTo[0], minute: availabilityTimeTo[1]).toUtc();
    return Availability(
      dayOfWeek: dayOfWeekFormat.format(timeFrom),
      time: Time(
        from: timeFormat.format(timeFrom).toLowerCase(),
        to: timeFormat.format(timeTo).toLowerCase()
      )
    );
  }
  
  static Availability getAvailabilityToLocal(Availability availability) {
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat); 
    DateFormat dayOfWeekFormat = DateFormat('EEEE');
    DateFormat timeFormat = DateFormat('ha');    
    DateTime date = resetTime(DateTime.now());
    while (dayOfWeekFormat.format(date) != availability.dayOfWeek) {
      date = getDSTAdjustedDateTime(date.add(Duration(days: 1)));
    }
    List<int> availabilityTimeFrom = convertTime12to24(availability.time?.from as String);
    List<int> availabilityTimeTo = convertTime12to24(availability.time?.to as String);
    final DateTime timeFrom = dateFormat.parseUTC(date.copyWith(hour: availabilityTimeFrom[0], minute: availabilityTimeFrom[1]).toString()).toLocal();
    final DateTime timeTo = dateFormat.parseUTC(date.copyWith(hour: availabilityTimeTo[0], minute: availabilityTimeTo[1]).toString()).toLocal();
    return Availability(
      dayOfWeek: dayOfWeekFormat.format(timeFrom),
      time: Time(
        from: timeFormat.format(timeFrom).toLowerCase(),
        to: timeFormat.format(timeTo).toLowerCase()
      )
    );
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

  static Future<void> showDatePickerAndroid({BuildContext? context, DateTime? initialDate, DateTime? firstDate, DateTime? lastDate, Function? setDate}) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context as BuildContext,
      locale: Locale(_defaultLocale.split('_')[0], _defaultLocale.split('_')[1]),
      initialDate: initialDate as DateTime,
      firstDate: firstDate != null ? firstDate : now,
      lastDate: lastDate != null ? lastDate : DateTime(now.year + 4),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light(),
          child: child!,
        );
      }
    );
    if (picked != null && picked != initialDate) {
      setDate!(picked);
    }
  }

  static void showDatePickerIOS({BuildContext? context, DateTime? initialDate, DateTime? firstDate, DateTime? lastDate, Function? setDate}) async {
    final DateTime now = DateTime.now();
    showModalBottomSheet(
      context: context as BuildContext,
      builder: (BuildContext builder) {
        return Wrap(
          children: [
            Container(
              color: AppColors.WILD_SAND,
              height: 40.0,
              child: InkWell(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  child: Text(
                    'common.done'.tr(),
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.blue
                    ), 
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              )
            ),
            Container(
              height: MediaQuery.of(context).copyWith().size.height / 3,
              color: Colors.white,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime? picked) {
                  if (picked != null && picked != initialDate) {
                    setDate!(picked);
                  }
                },
                initialDateTime: Jiffy(now).isBefore(Jiffy(initialDate!), Units.DAY) ? initialDate : now,
                minimumDate: firstDate != null ? firstDate : now,
                maximumDate: lastDate != null ? lastDate : DateTime(now.year + 4),
              ),
            ),
          ],
        );
      }
    );
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
  
  static String getIndefiniteArticle(String noun) {
    String article = 'common.a'.tr();
    if (AppConstants.vowels.contains(noun[0])) {
      article = 'common.an'.tr();
    }
    return article;
  }

  static bool isAvailabilityValid(Availability availability) {
    final int timeFrom = convertTime12to24(availability.time?.from as String)[0];
    final int timeTo = convertTime12to24(availability.time?.to as String)[0];
    return timeFrom < timeTo || timeFrom != timeTo && timeTo == 0;
  }

  static List getMergedAvailabilities(List<Availability>? userAvailabilities, String availabilityMergedMessage) {
    final List<Availability> availabilities = [];
    for (final String dayOfWeek in daysOfWeek) {
      final List<Availability> dayAvailabilities = [];
      if (userAvailabilities != null) {
        for (final Availability availability in userAvailabilities) {
          if (availability.dayOfWeek == dayOfWeek) {
            dayAvailabilities.add(availability);
          }
        }
      }
      final List<Availability> merged = [];
      int mergedLastTo = -1;
      _mergedAvailabilityLastShown = false;
      for (final Availability availability in dayAvailabilities) {
        if (merged.isNotEmpty) {
          mergedLastTo = convertTime12to24(merged.last.time?.to as String)[0];
        }
        final int availabilityFrom = convertTime12to24(availability.time?.from as String)[0];
        final int availabilityTo = convertTime12to24(availability.time?.to as String)[0];
        if (merged.isEmpty || mergedLastTo < availabilityFrom) {
          merged.add(availability);
        } else {
          if (mergedLastTo < availabilityTo) {
            availabilityMergedMessage = _setAvailabilityMergedMessage(availability, merged, availabilityMergedMessage);
            merged.last.time?.to = availability.time?.to;
          } else {
            availabilityMergedMessage = _setAvailabilityMergedMessage(availability, merged, availabilityMergedMessage);
          }
        }
      }
      availabilities.addAll(merged);
    }
    return [availabilities, availabilityMergedMessage];
  }

  static String _setAvailabilityMergedMessage(Availability availability, List<Availability> merged, String availabilityMergedMessage) {
    if (availabilityMergedMessage.isEmpty) {
      availabilityMergedMessage = 'common.availabilities_merged'.tr() + '\n';
    }    
    if (!_mergedAvailabilityLastShown) {
      String dayOfWeek = merged.last.dayOfWeek as String;
      String timeFrom = merged.last.time?.from as String;
      String timeTo = merged.last.time?.to as String;
      availabilityMergedMessage += dayOfWeek + ' ' + 'common.from'.tr() + ' ' + timeFrom + ' ' + 'common.to'.tr() + ' ' + timeTo + '\n';
      _mergedAvailabilityLastShown = true;
    }
    String dayOfWeek = availability.dayOfWeek as String;
    String timeFrom = availability.time?.from as String;
    String timeTo = availability.time?.to as String;    
    availabilityMergedMessage += dayOfWeek + ' ' + 'common.from'.tr() + ' ' + timeFrom + ' ' + 'common.to'.tr() + ' ' + timeTo + '\n';
    return availabilityMergedMessage;
  }  
}