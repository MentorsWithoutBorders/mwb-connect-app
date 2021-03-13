import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import '../../../utils/firebase_auth_mocks.dart';
import '../../../utils/test_app.dart';
import '../../../utils/widget_loader.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/name_widget.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseAuthMocks();  
  await Firebase.initializeApp();
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();  
  setupLocator();
  final getIt = GetIt.instance;
  await getIt.allReady();
  LocalStorageService storageService = locator<LocalStorageService>();
  storageService.userId = 'test_user';    

  group('Name widget tests:', () {
    var profileViewModel = locator<ProfileViewModel>();
    String jsonFile;

    Widget createNameWidget() {
      var widgetLoader = WidgetLoader();
      return widgetLoader.createLocalizedWidgetForTesting(
        child: TestApp(
          widget: Scaffold(
            body: Name()
          )
        ),
        jsonFile: jsonFile
      );
    }   

    setUp(() async {
      profileViewModel.profile = Profile();
      profileViewModel.profile.user = User(
        name: 'Bob'
      );
      jsonFile = await rootBundle.loadString('assets/i18n/en-US.json');
    });   

    testWidgets('Name widget shows up test', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createNameWidget());
        await tester.pump();
        await NameWidgetTest.nameShowsUpTest();
      });
    });

    testWidgets('Initial name test', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createNameWidget());
        await tester.pump();
        await NameWidgetTest.initialNameTest(tester);
      });
    });    

    testWidgets('Name change test', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createNameWidget());
        await tester.pump();
        await NameWidgetTest.nameChangeTest(tester);
      });
    });     
  });
}

class NameWidgetTest {
  static Finder nameField = find.byKey(Key(AppKeys.nameField));

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