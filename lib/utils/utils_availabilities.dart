import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/datetime_extension.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';

// ignore: avoid_classes_with_only_static_members
class UtilsAvailabilities {
  static bool _mergedAvailabilityLastShown = false; 

  static DateTime convertDayAndTimeToUtc(String dayOfWeek, String time) {
    DateFormat dayOfWeekFormat = DateFormat(AppConstants.dayOfWeekFormat, 'en');
    DateTime date = Utils.resetTime(DateTime.now());
    while (dayOfWeekFormat.format(date) != dayOfWeek) {
      date = Utils.getDSTAdjustedDateTime(date.add(Duration(days: 1)));
    }
    List<int> timeSplit = Utils.convertTime12to24(time);
    final DateTime dateTime = date.copyWith(hour: timeSplit[0], minute: timeSplit[1]).toUtc();
    return dateTime;
  }

  static DateTime convertDayAndTimeToLocal(String dayOfWeek, String time) {
    DateFormat dayOfWeekFormat = DateFormat(AppConstants.dayOfWeekFormat, 'en');
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en');
    DateTime date = Utils.resetTime(DateTime.now());
    while (dayOfWeekFormat.format(date) != dayOfWeek) {
      date = Utils.getDSTAdjustedDateTime(date.add(Duration(days: 1)));
    }
    List<String> timeSplit = time.split(':');
    int hours = int.parse(timeSplit[0]);
    int minutes = int.parse(timeSplit[1]);
    DateTime dateTime = date.copyWith(hour: hours, minute: minutes);
    dateTime = dateFormat.parseUTC(dateTime.toString()).toLocal();
    return dateTime;
  }

  static Availability getAvailabilityToUtc(Availability availability) {
    DateFormat dayOfWeekFormat = DateFormat(AppConstants.dayOfWeekFormat, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormat, 'en');
    DateTime date = Utils.resetTime(DateTime.now());
    while (dayOfWeekFormat.format(date) != availability.dayOfWeek) {
      date = Utils.getDSTAdjustedDateTime(date.add(Duration(days: 1)));
    }
    List<int> availabilityTimeFrom = Utils.convertTime12to24(availability.time?.from as String);
    List<int> availabilityTimeTo = Utils.convertTime12to24(availability.time?.to as String);
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
    DateFormat dateFormat = DateFormat(AppConstants.dateTimeFormat, 'en'); 
    DateFormat dayOfWeekFormat = DateFormat(AppConstants.dayOfWeekFormat, 'en');
    DateFormat timeFormat = DateFormat('h:mma', 'en');    
    DateTime date = Utils.resetTime(DateTime.now());
    while (dayOfWeekFormat.format(date) != availability.dayOfWeek) {
      date = Utils.getDSTAdjustedDateTime(date.add(Duration(days: 1)));
    }
    List<int> availabilityTimeFrom = Utils.convertTime12to24(availability.time?.from as String);
    List<int> availabilityTimeTo = Utils.convertTime12to24(availability.time?.to as String);
    DateTime timeFrom = dateFormat.parseUTC(date.copyWith(hour: availabilityTimeFrom[0], minute: availabilityTimeFrom[1]).toString()).toLocal();
    DateTime timeTo = dateFormat.parseUTC(date.copyWith(hour: availabilityTimeTo[0], minute: availabilityTimeTo[1]).toString()).toLocal();
    return Availability(
      dayOfWeek: dayOfWeekFormat.format(timeFrom),
      time: Time(
        from: timeFormat.format(timeFrom).toLowerCase(),
        to: timeFormat.format(timeTo).toLowerCase()
      )
    );
  }   

  static bool isAvailabilityValid(Availability availability) {
    final int timeFrom = Utils.convertTime12to24(availability.time?.from as String)[0];
    final int timeTo = Utils.convertTime12to24(availability.time?.to as String)[0];
    return timeFrom < timeTo || timeFrom != timeTo && timeTo == 0;
  }

  static List<Availability>? getSortedAvailabilities(List<Availability>? availabilities) {
    availabilities?.sort((a, b) => Utils.convertTime12to24(a.time?.from as String)[0].compareTo(Utils.convertTime12to24(b.time?.from as String)[0]));
    availabilities?.sort((a, b) => Utils.daysOfWeek.indexOf(a.dayOfWeek as String).compareTo(Utils.daysOfWeek.indexOf(b.dayOfWeek as String)));
    return availabilities;
  }   

  static List getMergedAvailabilities(List<Availability>? userAvailabilities, String availabilityMergedMessage) {
    final List<Availability> availabilities = [];
    for (final String dayOfWeek in Utils.daysOfWeek) {
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
          mergedLastTo = Utils.convertTime12to24(merged.last.time?.to as String)[0];
        }
        final int availabilityFrom = Utils.convertTime12to24(availability.time?.from as String)[0];
        final int availabilityTo = Utils.convertTime12to24(availability.time?.to as String)[0];
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