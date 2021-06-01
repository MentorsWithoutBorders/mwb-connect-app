import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goal_steps_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/notifications_view_model.dart';

class TestApp extends StatelessWidget {
  final Widget widget;

  TestApp({@required this.widget});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: locator<CommonViewModel>()),
        ChangeNotifierProvider.value(value: locator<ProfileViewModel>()),
        ChangeNotifierProvider.value(value: locator<GoalsViewModel>()),
        ChangeNotifierProvider.value(value: locator<GoalStepsViewModel>()),
        ChangeNotifierProvider.value(value: locator<QuizzesViewModel>()),
        ChangeNotifierProvider.value(value: locator<NotificationsViewModel>())
      ],
      child: MaterialApp(
        locale: EasyLocalization.of(context).locale,
        supportedLocales: EasyLocalization.of(context).supportedLocales,
        localizationsDelegates: EasyLocalization.of(context).delegates,
        theme: ThemeData(),
        home: widget
      )
    );
  }
}