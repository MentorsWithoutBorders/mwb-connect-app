import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/name_widget.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/widget_loader.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();  
  setupLocator();
  final getIt = GetIt.instance;
  await getIt.allReady();
  LocalStorageService storageService = locator<LocalStorageService>();
  storageService.userId = 'test_user';
  final String jsonFile = await rootBundle.loadString('assets/i18n/en-US.json');  

  group('Name widget tests:', () {
    final ProfileViewModel profileViewModel = locator<ProfileViewModel>();
    final WidgetLoader widgetLoader = WidgetLoader();
    final Widget nameWidget = widgetLoader.createWidget(widget: Name(), jsonFile: jsonFile);

    setUp(() async {
      profileViewModel.user = User(
        name: 'Bob',
        isMentor: true
      );
    });   

    testWidgets('Name widget shows up test', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(nameWidget);
        await tester.pump();
        await NameWidgetTest.nameShowsUpTest();
      });
    });

    testWidgets('Initial name test', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(nameWidget);
        await tester.pump();
        await NameWidgetTest.initialNameTest(tester);
      });
    });    

    testWidgets('Name change test', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(nameWidget);
        await tester.pump();
        await NameWidgetTest.nameChangeTest(tester);
      });
    });     
  });
}

// ignore: avoid_classes_with_only_static_members
class NameWidgetTest {
  static Finder nameField = find.byKey(const Key(AppKeys.nameField));

  static Future<void> nameShowsUpTest() async {
    expect(find.text('Name'), findsOneWidget);
    expect(nameField.last, findsOneWidget);
  }

  static Future<void> initialNameTest(WidgetTester tester) async {
    expect((tester.widget(nameField.last) as TextFormField).controller.text, equals('Bob'));
  }
  
  static Future<void> nameChangeTest(WidgetTester tester) async {
    await tester.enterText(nameField, 'Alice');
    await tester.pump();
    expect((tester.widget(nameField.last) as TextFormField).controller.text, equals('Alice'));
    await tester.enterText(nameField, 'Bob');
    await tester.pump();
    expect((tester.widget(nameField.last) as TextFormField).controller.text, equals('Bob'));    
  }    
}