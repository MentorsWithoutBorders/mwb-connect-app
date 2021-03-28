import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/availability_switch_widget.dart';

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

  group('Availability switch widget tests:', () {
    final WidgetLoader widgetLoader = WidgetLoader();
    final Widget availabilitySwitchWidget = widgetLoader.createWidget(widget: AvailabilitySwitch(), jsonFile: jsonFile);
    final ProfileViewModel profileViewModel = locator<ProfileViewModel>();  
    debugDefaultTargetPlatformOverride = TargetPlatform.android;  
    
    setUp(() async {
      profileViewModel.profile = Profile();
      profileViewModel.profile.user = User(
        isMentor: true,
        isAvailable: true   
      );
    });       

    testWidgets('Availability switch widget shows up test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(availabilitySwitchWidget);
        await tester.pump();
        await AvailabilitySwitchWidgetTest.widgetShowsUpTest();
      });
    });

    testWidgets('Initial value test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(availabilitySwitchWidget);
        await tester.pump();
        await AvailabilitySwitchWidgetTest.initialValueTest(tester);
      });
    });
    
    testWidgets('Change value test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(availabilitySwitchWidget);
        await tester.pump();
        await AvailabilitySwitchWidgetTest.changeValueTest(tester);
      });
    });
  });
}

// ignore: avoid_classes_with_only_static_members
class AvailabilitySwitchWidgetTest {
  static Finder availabilitySwitch = find.byKey(const Key(AppKeys.isAvailableSwitchAndroid));

  static Future<void> widgetShowsUpTest() async {
    expect(availabilitySwitch, findsOneWidget);
    expect(find.text('I\'m currently available'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;    
  }

  static Future<void> initialValueTest(WidgetTester tester) async {
    expect(((tester.widget(availabilitySwitch) as Switch).value as bool), equals(true));
  }  

  static Future<void> changeValueTest(WidgetTester tester) async {
    await tester.tap(availabilitySwitch);
    await tester.pumpAndSettle(Duration(seconds: 1));
    expect(((tester.widget(availabilitySwitch) as Switch).value as bool), equals(false));
    await tester.tap(availabilitySwitch);
    await tester.pumpAndSettle();
    expect(((tester.widget(availabilitySwitch) as Switch).value as bool), equals(true));
  } 
}