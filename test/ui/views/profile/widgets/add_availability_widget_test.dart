import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/add_availability_widget.dart';

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

  group('Add availability widget tests:', () {
    final WidgetLoader widgetLoader = WidgetLoader();
    final Widget addAvailabilityWidget = widgetLoader.createWidget(widget: AddAvailability(), jsonFile: jsonFile);  

    testWidgets('Add availability widget shows up test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(addAvailabilityWidget);
        await tester.pump();
        await AddAvailabilityWidgetTest.widgetShowsUpTest();
      });
    });

    testWidgets('Initial values test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(addAvailabilityWidget);
        await tester.pump();
        await AddAvailabilityWidgetTest.initialValuesTest(tester);
      });
    });
    
    testWidgets('Change values test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(addAvailabilityWidget);
        await tester.pump();
        await AddAvailabilityWidgetTest.changeValuesTest(tester);
      });
    });    
  });
}

// ignore: avoid_classes_with_only_static_members
class AddAvailabilityWidgetTest {
  static Finder dayOfWeekDropdown = find.byKey(const Key(AppKeys.dayOfWeekDropdown));
  static Finder timeFromDropdown = find.byKey(const Key(AppKeys.timeFromDropdown));
  static Finder timeToDropdown = find.byKey(const Key(AppKeys.timeToDropdown));
  static Finder addAvailabilityBtn = find.byKey(const Key(AppKeys.submitBtn));
  static Finder cancelBtn = find.byKey(const Key(AppKeys.cancelBtn));

  static Future<void> widgetShowsUpTest() async {
    expect(find.text('Add availability'), findsOneWidget);
    expect(dayOfWeekDropdown.last, findsOneWidget);
    expect(timeFromDropdown.last, findsOneWidget);
    expect(timeToDropdown.last, findsOneWidget);
    expect(addAvailabilityBtn.last, findsOneWidget);
    expect(cancelBtn.last, findsOneWidget);
  }

  static Future<void> initialValuesTest(WidgetTester tester) async {
    expect(((tester.widget(dayOfWeekDropdown.last) as DropdownButton).value as String), equals('Saturday'));
    expect(((tester.widget(timeFromDropdown.last) as DropdownButton).value as String), equals('10am'));
    expect(((tester.widget(timeToDropdown.last) as DropdownButton).value as String), equals('2pm'));
  }  

  static Future<void> changeValuesTest(WidgetTester tester) async {
    await tester.tap(dayOfWeekDropdown.last);
    await tester.pump();
    await tester.tap(find.text('Sunday').last);
    await tester.pump();
    expect(((tester.widget(dayOfWeekDropdown.last) as DropdownButton).value as String), equals('Sunday'));
    await tester.tap(timeFromDropdown.last);
    await tester.pump();
    await tester.tap(find.text('11am').last);
    await tester.pump();
    expect(((tester.widget(timeFromDropdown.last) as DropdownButton).value as String), equals('11am'));
    await tester.tap(timeToDropdown.last);
    await tester.pump();
    await tester.tap(find.text('3pm').last);
    await tester.pump();
    expect(((tester.widget(timeToDropdown.last) as DropdownButton).value as String), equals('3pm'));
    await tester.tap(addAvailabilityBtn.last);
    await tester.pump();
  }
}