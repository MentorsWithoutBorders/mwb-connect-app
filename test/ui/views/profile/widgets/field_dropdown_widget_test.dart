import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import '../../../utils/test_app.dart';
import '../../../utils/widget_loader.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/field_dropdown_widget.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';

void main() async {
  SharedPreferences.setMockInitialValues({});
  TestWidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  final getIt = GetIt.instance;
  await getIt.allReady();
  LocalStorageService storageService = locator<LocalStorageService>();
  storageService.userId = 'test_user';    

  group('Field dropdown widget tests:', () {
    var profileViewModel = locator<ProfileViewModel>();
    String jsonFile;

    Widget createFieldDropdownWidget() {
      var widgetLoader = WidgetLoader();
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

    testWidgets('Field dropdown shows up test', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createFieldDropdownWidget());
        await tester.pump();
        expect(find.text('Field'), findsOneWidget);
        expect(find.byType(FieldDropdown), findsOneWidget);
        expect(find.byKey(Key(AppKeys.fieldDropdown)).last, findsOneWidget);
      });
    });

    testWidgets('Initial field test', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createFieldDropdownWidget());
        await tester.pump();
        expect((((tester.widget(find.byKey(Key(AppKeys.fieldDropdown)).last) as DropdownButton).value) as Field).name, equals('Programming'));
      });
    });
    
    testWidgets('Change field test', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createFieldDropdownWidget());
        await tester.pump();
        await FieldDropdownWidgetTest.changeFieldTest(tester);
      });
    });    
  });
}

class FieldDropdownWidgetTest {
  static Future<void> changeFieldTest(WidgetTester tester) async {
    await tester.tap(find.byKey(Key(AppKeys.fieldDropdown)).last);
    await tester.pump();
    await tester.tap(find.text('Programming').last);
    await tester.pump();
    expect((((tester.widget(find.byKey(Key(AppKeys.fieldDropdown)).last) as DropdownButton).value) as Field).name, equals('Programming'));  
  }
}