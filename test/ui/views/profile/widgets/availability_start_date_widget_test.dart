import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/availability_start.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/availability_start_date_widget.dart';

import '../../../../utils/widget_loader.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();  
  setupLocator();
  final GetIt getIt = GetIt.instance;
  await getIt.allReady();
  final LocalStorageService storageService = locator<LocalStorageService>();
  storageService.userId = 'test_user';
  final String jsonFile = await rootBundle.loadString('assets/i18n/en-US.json');

  group('Availability start date widget tests:', () {
    final WidgetLoader widgetLoader = WidgetLoader();
    final Widget availabilityStartDateWidget = widgetLoader.createWidget(widget: AvailabilityStartDate(), jsonFile: jsonFile);
    final ProfileViewModel profileViewModel = locator<ProfileViewModel>();   
    
    setUp(() async {
      profileViewModel.profile = Profile();
      profileViewModel.profile.user = User(
        isMentor: true,
        isAvailable: true   
      );
    });       

    testWidgets('Availability start date widget shows up test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(availabilityStartDateWidget);
        await tester.pump();
        await AvailabilityStartDateWidgetTest.widgetShowsUpTest();
      });
    });

    testWidgets('Initial values test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(availabilityStartDateWidget);
        await tester.pump();
        await AvailabilityStartDateWidgetTest.initialValueTest(tester);
      });
    });
    
    testWidgets('Change option test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(availabilityStartDateWidget);
        await tester.pump();
        await AvailabilityStartDateWidgetTest.changeOptionTest(tester);
      });
    });

    testWidgets('Change date test', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android; 
      await tester.runAsync(() async {
        await tester.pumpWidget(availabilityStartDateWidget);
        await tester.pump();
        await AvailabilityStartDateWidgetTest.changeDateTest(tester);
      });
    });    
  });
}

// ignore: avoid_classes_with_only_static_members
class AvailabilityStartDateWidgetTest {
  static Finder currentlyAvailableRadio = find.byKey(const Key(AppKeys.currentlyAvailableRadio));
  static Finder currentlyAvailableText = find.byKey(const Key(AppKeys.currentlyAvailableText));
  static Finder availableFromRadio = find.byKey(const Key(AppKeys.availableFromRadio));
  static Finder availableFromText = find.byKey(const Key(AppKeys.availableFromText));
  static Finder availableFromDate = find.byKey(const Key(AppKeys.availableFromDate));
  static Finder editCalendarIcon = find.byKey(const Key(AppKeys.editCalendarIcon));
  static DateFormat dateFormat = DateFormat('MMM dd, yyyy');

  static Future<void> widgetShowsUpTest() async {
    expect(find.text('I\'m currently available'), findsOneWidget);
    expect(currentlyAvailableRadio, findsOneWidget);    
    expect(currentlyAvailableText, findsOneWidget);    
    expect(find.text('I\'m available starting from:'), findsOneWidget);
    expect(availableFromRadio, findsOneWidget);
    expect(availableFromText, findsOneWidget);
    expect(availableFromDate, findsOneWidget);
    expect(editCalendarIcon, findsOneWidget);
  }

  static Future<void> initialValueTest(WidgetTester tester) async {
    await tester.pumpAndSettle(Duration(seconds: 1));
    expect(((tester.widget(currentlyAvailableRadio) as Radio).groupValue as AvailabilityStart), equals(AvailabilityStart.now));
    expect(((tester.widget(availableFromRadio) as Radio).groupValue as AvailabilityStart), equals(AvailabilityStart.now));
    expect(find.text(dateFormat.format(DateTime.now())), findsOneWidget);
  }  

  static Future<void> changeOptionTest(WidgetTester tester) async {
    await tester.tap(availableFromRadio);
    await tester.pump();
    expect(((tester.widget(currentlyAvailableRadio) as Radio).groupValue as AvailabilityStart), equals(AvailabilityStart.later));
    expect(((tester.widget(availableFromRadio) as Radio).groupValue as AvailabilityStart), equals(AvailabilityStart.later));
    await tester.tap(currentlyAvailableRadio);
    await tester.pump();
    expect(((tester.widget(currentlyAvailableRadio) as Radio).groupValue as AvailabilityStart), equals(AvailabilityStart.now));
    expect(((tester.widget(availableFromRadio) as Radio).groupValue as AvailabilityStart), equals(AvailabilityStart.now));    
    await tester.tap(availableFromText);
    await tester.pump();
    expect(((tester.widget(currentlyAvailableRadio) as Radio).groupValue as AvailabilityStart), equals(AvailabilityStart.later));
    expect(((tester.widget(availableFromRadio) as Radio).groupValue as AvailabilityStart), equals(AvailabilityStart.later));
    await tester.tap(currentlyAvailableText);
    await tester.pump();
    expect(((tester.widget(currentlyAvailableRadio) as Radio).groupValue as AvailabilityStart), equals(AvailabilityStart.now));
    expect(((tester.widget(availableFromRadio) as Radio).groupValue as AvailabilityStart), equals(AvailabilityStart.now));    
  } 

  static Future<void> changeDateTest(WidgetTester tester) async {
    await tester.tap(currentlyAvailableRadio);
    await tester.pump();    
    await tester.tap(editCalendarIcon);
    await tester.pumpAndSettle();
    await tester.tap(find.text('29'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(((tester.widget(currentlyAvailableRadio) as Radio).groupValue as AvailabilityStart), equals(AvailabilityStart.later));
    expect(((tester.widget(availableFromRadio) as Radio).groupValue as AvailabilityStart), equals(AvailabilityStart.later));
    DateTime now = DateTime.now();
    String nowFormatted = dateFormat.format(now);
    String date = nowFormatted.replaceAll(now.day.toString().padLeft(2, '0'), '29');
    expect(find.text(date), findsOneWidget);
    await tester.tap(currentlyAvailableRadio);
    await tester.pump();   
    await tester.tap(availableFromDate);
    await tester.pumpAndSettle();
    await tester.tap(find.text('30'));
    await tester.pumpAndSettle();    
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();    
    expect(((tester.widget(currentlyAvailableRadio) as Radio).groupValue as AvailabilityStart), equals(AvailabilityStart.later));
    expect(((tester.widget(availableFromRadio) as Radio).groupValue as AvailabilityStart), equals(AvailabilityStart.later));
    date = nowFormatted.replaceAll(now.day.toString().padLeft(2, '0'), '30');
    expect(find.text(date), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  } 
}