import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/field_dropdown_widget.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/firebase_auth_mocks.dart';
import '../../../utils/test_app.dart';
import '../../../utils/widget_loader.dart';

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

  group('Field dropdown widget tests:', () {
    final ProfileViewModel profileViewModel = locator<ProfileViewModel>();
    String jsonFile;

    Widget createFieldDropdownWidget() {
      final WidgetLoader widgetLoader = WidgetLoader();
      return widgetLoader.createLocalizedWidgetForTesting(
        child: TestApp(
          widget: Scaffold(
            body: FieldDropdown()
          )
        ),
        jsonFile: jsonFile
      );
    }    

    setUp(() async {
      profileViewModel.profile = Profile();
      profileViewModel.profile.user = User(
        name: 'Bob',
        field: 'Programming'
      );
      profileViewModel.profile.fields = [
        Field(
          name: 'Programming'
        ),
        Field(
          name: 'Graphic Design'
        ),
      ];
      jsonFile = await rootBundle.loadString('assets/i18n/en-US.json');
    });

    testWidgets('Field dropdown shows up test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createFieldDropdownWidget());
        await tester.pump();
        await FieldDropdownWidgetTest.fieldShowsUpTest();
      });
    });

    testWidgets('Initial field test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createFieldDropdownWidget());
        await tester.pump();
        await FieldDropdownWidgetTest.initialFieldTest(tester);
      });
    });
    
    testWidgets('Change field test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createFieldDropdownWidget());
        await tester.pump();
        await FieldDropdownWidgetTest.changeFieldTest(tester);
      });
    });    
  });
}

// ignore: avoid_classes_with_only_static_members
class FieldDropdownWidgetTest {
  static Finder fieldDropdown = find.byKey(const Key(AppKeys.fieldDropdown));

  static Future<void> fieldShowsUpTest() async {
    expect(find.text('Field'), findsOneWidget);
    expect(find.byType(FieldDropdown), findsOneWidget);
    expect(fieldDropdown.last, findsOneWidget); 
  }

  static Future<void> initialFieldTest(WidgetTester tester) async {
    expect(((tester.widget(fieldDropdown.last) as DropdownButton).value as Field).name, equals('Programming'));  
  }  

  static Future<void> changeFieldTest(WidgetTester tester) async {
    await tester.tap(fieldDropdown.last);
    await tester.pump();
    await tester.tap(find.text('Graphic Design').last);
    await tester.pump();
    expect(((tester.widget(fieldDropdown.last) as DropdownButton).value as Field).name, equals('Graphic Design'));
    await tester.tap(fieldDropdown.last);
    await tester.pump();
    await tester.tap(find.text('Programming').last);
    await tester.pump();
    expect(((tester.widget(fieldDropdown.last) as DropdownButton).value as Field).name, equals('Programming'));
  }
}