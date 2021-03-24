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
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/availability_list_widget.dart';

import '../../../../utils/firebase_auth_mocks.dart';
import '../../../../utils/widget_loader.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseAuthMocks();  
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

    setUp(() async {
      final EasyLocalizationController easyLocalizationController = widgetLoader.createEasyLocalizationController(jsonFile: jsonFile);
      await easyLocalizationController.loadTranslations();
      Localization.load(Locale('en', 'US'), translations: easyLocalizationController.translations);

      profileViewModel.profile = Profile();
      profileViewModel.profile.user = User(
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
        await AvailabilityListWidgetTest.addBaseItems(tester);
        await AvailabilityListWidgetTest.addItemWithMergeTest(tester);
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
  static Finder deleteAvailabilityBtn1 = find.byKey(const Key(AppKeys.deleteAvailabilityBtn + '1'));
  static Finder addAvailabilityBtn = find.byKey(const Key(AppKeys.addAvailabilityBtn));
  static Finder dayOfWeekDropdown = find.byKey(const Key(AppKeys.dayOfWeekDropdown)).last;
  static Finder timeFromDropdown = find.byKey(const Key(AppKeys.timeFromDropdown)).last;
  static Finder timeToDropdown = find.byKey(const Key(AppKeys.timeToDropdown)).last;
  static Finder submitBtn = find.byKey(const Key(AppKeys.submitBtn));
  static Finder cancelBtn = find.byKey(const Key(AppKeys.cancelBtn));
  static Finder toast = find.byKey(const Key(AppKeys.toast));

  static Future<void> widgetShowsUpTest() async {
    expect(find.text('Availability'), findsOneWidget);
    expect(find.text('Add availability'), findsOneWidget);
    expect(addAvailabilityBtn, findsOneWidget);
  }

  static Future<void> addItemsTest(WidgetTester tester) async {
    await addBaseItems(tester);
    expect(find.text('Wednesday:'), findsOneWidget);
    expect(find.text('3pm - 5pm'), findsOneWidget);
    expect(find.text('Saturday:'), findsOneWidget);
    expect(find.text('10am - 2pm'), findsOneWidget);      
  }

  static Future<void> addItemWithMergeTest(WidgetTester tester) async {
    await tester.tap(addAvailabilityBtn);
    await tester.pumpAndSettle();
    Availability availability = Availability(dayOfWeek: 'Saturday', time: Time(from: '12pm', to: '3pm'));
    await addItem(tester, availability);
    expect(find.text('Wednesday:'), findsOneWidget);
    expect(find.text('3pm - 5pm'), findsOneWidget);
    expect(find.text('Saturday:'), findsOneWidget);
    expect(find.text('10am - 3pm'), findsOneWidget);
    expect(toast, findsOneWidget);
    expect(find.text('The following availabilities have been merged:\nSaturday from 10am to 2pm\nSaturday from 12pm to 3pm\n'), findsOneWidget);
  }  

 static Future<void> addBaseItems(WidgetTester tester) async {
    await tester.tap(addAvailabilityBtn);
    await tester.pumpAndSettle();
    await tester.tap(submitBtn);
    await tester.pump();
    await tester.tap(addAvailabilityBtn);
    await tester.pumpAndSettle();    
    Availability availability = Availability(dayOfWeek: 'Wednesday', time: Time(from: '3pm', to: '5pm'));
    await addItem(tester, availability);  
  }  
  
  static Future<void> addItem(WidgetTester tester, Availability availability) async {
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

  static Future<void> deleteItemTest(WidgetTester tester) async {
    await tester.tap(deleteAvailabilityBtn0);
    await tester.pump();
    expect(availabilityItem0, findsOneWidget); 
    expect(find.text('Saturday:'), findsOneWidget);
    expect(find.text('10am - 2pm'), findsOneWidget);
    await tester.tap(deleteAvailabilityBtn0);
    await tester.pump();
    expect(find.text('Saturday:'), findsNothing);
  }  
}