import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/datetime_extension.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';

// ignore: avoid_classes_with_only_static_members
class Utils {
  static final String _defaultLocale = Platform.localeName;

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

  static Availability getAvailabilityToUtc(Availability availability) {
    DateFormat dayOfWeekFormat = DateFormat('EEEE');
    DateFormat timeFormat = DateFormat('ha');
    DateTime date = Utils.resetTime(DateTime.now());
    while (dayOfWeekFormat.format(date) != availability.dayOfWeek) {
      date = Jiffy(date).add(days: 1).dateTime;
    }    
    final DateTime timeFrom = date.copyWith(hour: Utils.convertTime12to24(availability.time.from)).toUtc();
    final DateTime timeTo = date.copyWith(hour: Utils.convertTime12to24(availability.time.to)).toUtc();
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
    DateTime date = Utils.resetTime(DateTime.now());
    while (dayOfWeekFormat.format(date) != availability.dayOfWeek) {
      date = Jiffy(date).add(days: 1).dateTime;
    }    
    final DateTime timeFrom = dateFormat.parseUTC(date.copyWith(hour: convertTime12to24(availability.time.from)).toString()).toLocal();
    final DateTime timeTo = dateFormat.parseUTC(date.copyWith(hour: Utils.convertTime12to24(availability.time.to)).toString()).toLocal();
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
  
  static String getUrlType(String url) {
    if (url.contains('meet')) {
      return 'Google Meet';
    } else if (url.contains('zoom')) {
      return 'Zoom';
    } else {
      return '';
    }
  }

  static Future<void> showDatePickerAndroid({BuildContext context, DateTime initialDate, DateTime firstDate, DateTime lastDate, Function setDate}) async {
    final DateTime now = DateTime.now();
    final DateTime picked = await showDatePicker(
      context: context,
      locale: Locale(_defaultLocale.split('_')[0], _defaultLocale.split('_')[1]),
      initialDate: initialDate,
      firstDate: firstDate != null ? firstDate : now,
      lastDate: lastDate != null ? lastDate : DateTime(now.year + 4),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      }
    );
    if (picked != null && picked != initialDate) {
      setDate(picked);
    }
  }

  static void showDatePickerIOS({BuildContext context, DateTime initialDate, DateTime firstDate, DateTime lastDate, Function setDate}) async {
    final DateTime now = DateTime.now();
    showModalBottomSheet(
      context: context,
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
                onDateTimeChanged: (DateTime picked) {
                  if (picked != null && picked != initialDate) {
                    setDate(picked);
                  }
                },
                initialDateTime: initialDate,
                minimumDate: firstDate != null ? firstDate : now,
                maximumDate: lastDate != null ? lastDate : DateTime(now.year + 4),
              ),
            ),
          ],
        );
      }
    );
  }      
}