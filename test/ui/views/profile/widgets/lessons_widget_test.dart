import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/lessons_widget.dart';

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

  group('Lessons availability widget tests:', () {
    final WidgetLoader widgetLoader = WidgetLoader();
    final Widget lessonsAvailabilityWidget = widgetLoader.createWidget(widget: Lessons(), jsonFile: jsonFile);
    final ProfileViewModel profileViewModel = locator<ProfileViewModel>();    
    
   setUp(() async {
      final EasyLocalizationController easyLocalizationController = widgetLoader.createEasyLocalizationController(jsonFile: jsonFile);
      await easyLocalizationController.loadTranslations();
      Localization.load(Locale('en', 'US'), translations: easyLocalizationController.translations);

      profileViewModel.profile = Profile();
      profileViewModel.profile.user = User(
        isMentor: true,
        lessonsAvailability: LessonsAvailability(
          minInterval: 2,
          minIntervalUnit: 'week'
        )
      );
    });       

    testWidgets('Lessons availability widget shows up test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(lessonsAvailabilityWidget);
        await tester.pump();
        await LessonsWidgetTest.widgetShowsUpTest();
      });
    });

    testWidgets('Initial values test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(lessonsAvailabilityWidget);
        await tester.pump();
        await LessonsWidgetTest.initialValuesTest(tester);
      });
    });
    
    testWidgets('Change min interval test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(lessonsAvailabilityWidget);
        await tester.pump();
        await LessonsWidgetTest.changeMinIntervalTest(tester);
      });
    });      
  });
}

// ignore: avoid_classes_with_only_static_members
class LessonsWidgetTest {
  static Finder minIntervalDropdown = find.byKey(const Key(AppKeys.minIntervalDropdown)).last;
  static Finder minIntervalUnitDropdown = find.byKey(const Key(AppKeys.minIntervalUnitDropdown)).last;

  static Future<void> widgetShowsUpTest() async {
    expect(minIntervalDropdown, findsOneWidget);
    expect(minIntervalUnitDropdown, findsOneWidget);
  }

  static Future<void> initialValuesTest(WidgetTester tester) async {
    expect(((tester.widget(minIntervalDropdown) as DropdownButton).value as int), equals(2));
    expect(((tester.widget(minIntervalUnitDropdown) as DropdownButton).value as String), equals('weeks')); 
  }  

  static Future<void> changeMinIntervalTest(WidgetTester tester) async {
    await tester.tap(minIntervalDropdown);
    await tester.pump();
    await tester.tap(find.text('3').last);
    await tester.pump();
    expect(((tester.widget(minIntervalDropdown) as DropdownButton).value as int), equals(3));
    await tester.tap(minIntervalUnitDropdown);
    await tester.pump();
    await tester.tap(find.text('months').last);
    await tester.pump();
    expect(((tester.widget(minIntervalUnitDropdown) as DropdownButton).value as String), equals('months'));
    await tester.tap(minIntervalDropdown);
    await tester.pump();
    await tester.tap(find.text('1').last);
    await tester.pump();
    expect(((tester.widget(minIntervalDropdown) as DropdownButton).value as int), equals(1));
    await tester.tap(minIntervalUnitDropdown);
    await tester.pump();
    await tester.tap(find.text('week').last);
    await tester.pump();
    expect(((tester.widget(minIntervalUnitDropdown) as DropdownButton).value as String), equals('week'));    
  }  
}