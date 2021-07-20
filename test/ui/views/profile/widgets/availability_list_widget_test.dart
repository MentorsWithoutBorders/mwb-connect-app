import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/availability_list_widget.dart';

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

  group('Availability list widget tests:', () {
    final WidgetLoader widgetLoader = WidgetLoader();
    final Widget availabilityListWidget = widgetLoader.createWidget(widget: AvailabilityList(), jsonFile: jsonFile);
    final ProfileViewModel profileViewModel = locator<ProfileViewModel>();

    setUpAll(() async {
      final EasyLocalizationController easyLocalizationController = widgetLoader.createEasyLocalizationController(jsonFile: jsonFile);
      await easyLocalizationController.loadTranslations();
      Localization.load(Locale('en', 'US'), translations: easyLocalizationController.translations);

      profileViewModel.user = User(
        isMentor: true,
        isAvailable: true,
        availabilities: []    
      );
    });      

    testWidgets('Availability list widget shows up test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(availabilityListWidget);
        await tester.pump();
        await AvailabilityListWidgetTest.widgetShowsUpTest();
      });
    });

    testWidgets('Add availability items test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(availabilityListWidget);
        await tester.pump();
        await AvailabilityListWidgetTest.addItemsTest(tester);
      });
    });
    
    testWidgets('Add availability item with merge test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(availabilityListWidget);
        await tester.pump();
        await AvailabilityListWidgetTest.addItemWithMergeTest(tester);
      });
    });

    testWidgets('Edit availability item test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(availabilityListWidget);
        await tester.pump();
        await AvailabilityListWidgetTest.editItemTest(tester);
      });
    });

    testWidgets('Edit availability item with merge test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(availabilityListWidget);
        await tester.pump();
        await AvailabilityListWidgetTest.editItemWithMergeTest(tester);
      });
    });     
    
    testWidgets('Delete availability item test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(availabilityListWidget);
        await tester.pump();
        await AvailabilityListWidgetTest.deleteItemTest(tester);
      });
    });
  });
}

// ignore: avoid_classes_with_only_static_members
class AvailabilityListWidgetTest {
  static Finder availabilityItem0 = find.byKey(const Key(AppKeys.availabilityItem + '0'));
  static Finder availabilityItem1 = find.byKey(const Key(AppKeys.availabilityItem + '1'));
  static Finder deleteAvailabilityBtn0 = find.byKey(const Key(AppKeys.deleteAvailabilityBtn + '0'));
  static Finder addAvailabilityBtn = find.byKey(const Key(AppKeys.addAvailabilityBtn));
  static Finder dayOfWeekDropdown = find.byKey(const Key(AppKeys.dayOfWeekDropdown)).last;
  static Finder timeFromDropdown = find.byKey(const Key(AppKeys.timeFromDropdown)).last;
  static Finder timeToDropdown = find.byKey(const Key(AppKeys.timeToDropdown)).last;
  static Finder submitBtn = find.byKey(const Key(AppKeys.submitBtn));
  static Finder cancelBtn = find.byKey(const Key(AppKeys.cancelBtn));
  static Finder toast = find.byKey(const Key(AppKeys.toast));

  static Future<void> widgetShowsUpTest() async {
    expect(find.text('Available days/times'), findsOneWidget);
    expect(find.text('Add availability'), findsOneWidget);
    expect(addAvailabilityBtn, findsOneWidget);
  }

  static Future<void> addItemsTest(WidgetTester tester) async {
    await tester.tap(addAvailabilityBtn);
    await tester.pumpAndSettle();    
    Availability availability = Availability(dayOfWeek: 'Friday', time: Time(from: '3pm', to: '5pm'));
    await _submitItem(tester, availability);
    await tester.tap(addAvailabilityBtn);
    await tester.pumpAndSettle();    
    availability = Availability(dayOfWeek: 'Wednesday', time: Time(from: '11am', to: '3pm'));
    await _submitItem(tester, availability);      
    expect(find.text('Wednesday:'), findsOneWidget);
    expect(find.text('11am - 3pm'), findsOneWidget);
    expect(find.text('Friday:'), findsOneWidget);
    expect(find.text('3pm - 5pm'), findsOneWidget);      
  }

  static Future<void> addItemWithMergeTest(WidgetTester tester) async {
    await tester.tap(addAvailabilityBtn);
    await tester.pumpAndSettle();
    Availability availability = Availability(dayOfWeek: 'Friday', time: Time(from: '1pm', to: '4pm'));
    await _submitItem(tester, availability);
    await tester.pumpAndSettle(Duration(seconds: 2));
    expect(find.text('Wednesday:'), findsOneWidget);
    expect(find.text('11am - 3pm'), findsOneWidget);
    expect(find.text('Friday:'), findsOneWidget);
    expect(find.text('1pm - 5pm'), findsOneWidget);
    expect(toast, findsOneWidget);
    expect(find.text('The following availabilities have been merged:\nFriday from 1pm to 4pm\nFriday from 3pm to 5pm\n'), findsOneWidget);
  }
  
  static Future<void> _submitItem(WidgetTester tester, Availability availability) async {
    await tester.tap(dayOfWeekDropdown);
    await tester.pump();
    await tester.tap(find.text(availability.dayOfWeek).last);
    await tester.pump();
    await tester.tap(timeFromDropdown);
    await tester.pump();
    await tester.tap(find.text(availability.time.from).last);
    await tester.pump();
    await tester.tap(timeToDropdown);
    await tester.pump();
    await tester.tap(find.text(availability.time.to).last);
    await tester.pump();
    await tester.tap(submitBtn);
    await tester.pump();
  }
  
  static Future<void> editItemTest(WidgetTester tester) async {
    await tester.tap(find.text('1pm - 5pm'));
    await tester.pumpAndSettle();
    Availability availability = Availability(dayOfWeek: 'Thursday', time: Time(from: '4pm', to: '6pm'));
    await _submitItem(tester, availability);
    expect(find.text('Wednesday:'), findsOneWidget);
    expect(find.text('11am - 3pm'), findsOneWidget);
    expect(find.text('Thursday:'), findsOneWidget);
    expect(find.text('4pm - 6pm'), findsOneWidget);    
  }

  static Future<void> editItemWithMergeTest(WidgetTester tester) async {
    await tester.tap(find.text('4pm - 6pm'));
    await tester.pumpAndSettle();
    Availability availability = Availability(dayOfWeek: 'Wednesday', time: Time(from: '2pm', to: '5pm'));
    await _submitItem(tester, availability);
    await tester.pumpAndSettle(Duration(seconds: 2));
    expect(find.text('Wednesday:'), findsOneWidget);
    expect(find.text('11am - 5pm'), findsOneWidget);
    expect(find.text('Thursday:'), findsNothing);
    expect(find.text('4pm - 6pm'), findsNothing);     
    expect(toast, findsOneWidget);
    expect(find.text('The following availabilities have been merged:\nWednesday from 11am to 3pm\nWednesday from 2pm to 5pm\n'), findsOneWidget);
    await tester.pump(Duration(seconds: 4));
  }  

  static Future<void> deleteItemTest(WidgetTester tester) async {
    await tester.tap(deleteAvailabilityBtn0);
    await tester.pump(Duration(seconds: 1));
    expect(availabilityItem0, findsNothing); 
    expect(availabilityItem1, findsNothing); 
  }  
}