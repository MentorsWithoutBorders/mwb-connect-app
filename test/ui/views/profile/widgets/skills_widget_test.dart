import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/skills_widget.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  group('Skills widget tests:', () {
    final ProfileViewModel profileViewModel = locator<ProfileViewModel>();
    final WidgetLoader widgetLoader = WidgetLoader();
    final Widget skillsWidget = widgetLoader.createWidget(widget: Skills(index: 0), jsonFile: jsonFile);
    final Finder addSkillsField = find.byKey(const Key(AppKeys.addSkillsField));

    setUp(() async {
      profileViewModel.user = User(
        name: 'Bob',
        field: 'Programming',
        subfields: [
          Subfield(
            name: 'Web Development',
            skills: []
          )
        ]
      );
      profileViewModel.fields = [
        Field(
          name: 'Programming',
          subfields: [
            Subfield(
              name: 'Web Development',
              skills: [
                'HTML',
                'CSS',
                'JavaScript',
                'Python',
                'Java'
              ]
            )
          ]
        )
      ];
    });

    testWidgets('Skills widget shows up test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(skillsWidget);
        await tester.pump();
        await SkillsWidgetTest.skillsWidgetShowsUpTest();
      });
    });

    testWidgets('Add skills test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(skillsWidget);
        await tester.pump();
        await SkillsWidgetTest.addSkillsTest(tester);       
      });
    });
    
    testWidgets('Delete skills test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(skillsWidget);
        await tester.pump();
        await tester.tap(addSkillsField);
        await tester.pump();
        await tester.tap(find.text('HTML'));
        await tester.pump();        
        await tester.tap(find.text('CSS'));
        await tester.pump();
        await SkillsWidgetTest.deleteSkillsTest(tester);      
      });
    });      
  });
}

// ignore: avoid_classes_with_only_static_members
class SkillsWidgetTest {
  static Finder addSkillsField = find.byKey(const Key(AppKeys.addSkillsField));
  static Finder skillTag0 = find.byKey(const Key(AppKeys.skillTag + '0'));
  static Finder skillTag1 = find.byKey(const Key(AppKeys.skillTag + '1'));
  static Finder skillText0 = find.byKey(const Key(AppKeys.skillText + '0'));
  static Finder skillText1 = find.byKey(const Key(AppKeys.skillText + '1'));  
  static Finder deleteSkillBtn0 = find.byKey(const Key(AppKeys.deleteSkillBtn + '0'));
  static Finder deleteSkillBtn1 = find.byKey(const Key(AppKeys.deleteSkillBtn + '1'));
  
  static Future<void> skillsWidgetShowsUpTest() async {
    expect(addSkillsField, findsOneWidget);
    expect(find.text('Add skills (e.g. HTML, CSS, JavaScript, etc.)'), findsOneWidget);
  }

  static Future<void> addSkillsTest(WidgetTester tester) async {
    await tester.tap(addSkillsField);
    await tester.pump();
    await tester.tap(find.text('HTML'));
    await tester.pump();
    expect(skillTag0, findsOneWidget);
    expect((tester.widget(skillText0) as Text).data, equals('HTML'));
    await tester.enterText(addSkillsField, 'css');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(skillTag1, findsOneWidget);
    expect((tester.widget(skillText1) as Text).data, equals('CSS'));
  }

  static Future<void> deleteSkillsTest(WidgetTester tester) async {
    await tester.tap(deleteSkillBtn0);
    await tester.pump();
    await tester.tap(deleteSkillBtn0);
    await tester.pump();
    expect(skillTag0, findsNothing);
    expect(skillTag1, findsNothing);
  }  

}