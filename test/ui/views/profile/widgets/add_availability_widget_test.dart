import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
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
    final ProfileViewModel profileViewModel = locator<ProfileViewModel>();    
    
   setUp(() async {
      profileViewModel.profile = Profile();
      profileViewModel.profile.user = User(
        isMentor: true,
        isAvailable: true,
        availabilities: []    
      );
    });       

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

    testWidgets('"To" time before "from" test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(addAvailabilityWidget);
        await tester.pump();
        await AddAvailabilityWidgetTest.toTimeBeforeFromTest(tester);
      });
    });    
  });
}

// ignore: avoid_classes_with_only_static_members
class AddAvailabilityWidgetTest {
  static Finder dayOfWeekDropdown = find.byKey(const Key(AppKeys.dayOfWeekDropdown)).last;
  static Finder timeFromDropdown = find.byKey(const Key(AppKeys.timeFromDropdown)).last;
  static Finder timeToDropdown = find.byKey(const Key(AppKeys.timeToDropdown)).last;
  static Finder submitBtn = find.byKey(const Key(AppKeys.submitBtn));
  static Finder cancelBtn = find.byKey(const Key(AppKeys.cancelBtn));

  static Future<void> widgetShowsUpTest() async {
    expect(dayOfWeekDropdown, findsOneWidget);
    expect(timeFromDropdown, findsOneWidget);
    expect(timeToDropdown, findsOneWidget);
    expect(submitBtn, findsOneWidget);
    expect(cancelBtn, findsOneWidget);
  }

  static Future<void> initialValuesTest(WidgetTester tester) async {
    expect(((tester.widget(dayOfWeekDropdown) as DropdownButton).value as String), equals('Saturday'));
    expect(((tester.widget(timeFromDropdown) as DropdownButton).value as String), equals('10am'));
    expect(((tester.widget(timeToDropdown) as DropdownButton).value as String), equals('2pm')); 
  }  

  static Future<void> changeValuesTest(WidgetTester tester) async {
    await tester.tap(dayOfWeekDropdown);
    await tester.pump();
    await tester.tap(find.text('Wednesday').last);
    await tester.pump();
    expect(((tester.widget(dayOfWeekDropdown) as DropdownButton).value as String), equals('Wednesday'));
    await tester.tap(timeFromDropdown);
    await tester.pump();
    await tester.tap(find.text('4pm').last);
    await tester.pump();
    expect(((tester.widget(timeFromDropdown) as DropdownButton).value as String), equals('4pm'));
    await tester.tap(timeToDropdown);
    await tester.pump();
    await tester.tap(find.text('6pm').last);
    await tester.pump();
    expect(((tester.widget(timeToDropdown) as DropdownButton).value as String), equals('6pm'));
  }

  static Future<void> toTimeBeforeFromTest(WidgetTester tester) async {
    await tester.tap(timeFromDropdown);
    await tester.pump();
    await tester.tap(find.text('5pm').last);
    await tester.pump();
    await tester.tap(timeToDropdown);
    await tester.pump();
    await tester.tap(find.text('3pm').last);
    await tester.pump();
    await tester.tap(submitBtn);
    await tester.pumpAndSettle();
    expect(find.text('"From" time cannot be equal to or after "to" time'), findsOneWidget);
  }  
}