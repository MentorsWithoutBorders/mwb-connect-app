import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mwb_connect_app/utils/colors.dart';

// ignore: avoid_classes_with_only_static_members
class UtilsDatePickers {
  static final String _defaultLocale = Platform.localeName;

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
}