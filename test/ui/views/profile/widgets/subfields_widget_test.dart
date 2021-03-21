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
import 'package:mwb_connect_app/ui/views/profile/widgets/field_dropdown_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/subfield_dropdown_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/subfields_widget.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  group('Subfield dropdown widget tests:', () {
    final ProfileViewModel profileViewModel = locator<ProfileViewModel>();
    final WidgetLoader widgetLoader = WidgetLoader();
    final Widget wrapWidget = Wrap(
      children: [
        FieldDropdown(),
        Subfields()
      ],
    );
    final Widget subfieldsWidget = widgetLoader.createWidget(widget: wrapWidget, jsonFile: jsonFile);    
    final Finder addSubfieldBtn = find.byKey(const Key(AppKeys.addSubfieldBtn)); 

    setUp(() async {
      profileViewModel.profile = Profile();
      profileViewModel.profile.user = User(
        name: 'Bob',
        field: 'Programming',
        subfields: []
      );
      profileViewModel.profile.fields = [
        Field(
          name: 'Programming',
          subfields: [
            Subfield(name: 'Web Development'),
            Subfield(name: 'Mobile Development'),
            Subfield(name: 'Game Development'),
          ]
        ),
        Field(
          name: 'Graphic Design',
          subfields: [
            Subfield(name: 'Visual Identity'),
            Subfield(name: 'Marketing & Advertising'),
            Subfield(name: 'User Interface'),
          ]
        ),
      ];
    });

    testWidgets('Subfields widgets shows up test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(subfieldsWidget);
        await tester.pump();
        await SubfieldsWidgetTest.subfieldsWidgetShowsUpTest();
      });
    });

    testWidgets('Add subfield test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(subfieldsWidget);
        await tester.pump();
        await SubfieldsWidgetTest.addSubfieldTest(tester);       
      });
    });

    testWidgets('Change subfield test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(subfieldsWidget);
        await tester.pump();
        await tester.tap(addSubfieldBtn.last);
        await tester.pump();        
        await SubfieldsWidgetTest.changeSubfieldTest(tester);
      });
    });
    
    testWidgets('Delete subfields test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(subfieldsWidget);
        await tester.pump();
        await tester.tap(addSubfieldBtn.last);
        await tester.pump();
        await tester.tap(addSubfieldBtn.last);
        await tester.pump();           
        await SubfieldsWidgetTest.deleteSubfieldTest(tester);      
      });
    });      
  });
}

// ignore: avoid_classes_with_only_static_members
class SubfieldsWidgetTest {
  static Finder addSubfieldBtn = find.byKey(const Key(AppKeys.addSubfieldBtn));
  static Finder subfieldDropdown0 = find.byKey(const Key(AppKeys.subfieldDropdown + '0'));
  static Finder subfieldDropdown1 = find.byKey(const Key(AppKeys.subfieldDropdown + '1'));
  static Finder deleteSubfieldBtn0 = find.byKey(const Key(AppKeys.deleteSubfieldBtn + '0'));
  
  static Future<void> subfieldsWidgetShowsUpTest() async {
    expect(find.text('Subfields'), findsOneWidget);
  }

  static Future<void> addSubfieldTest(WidgetTester tester) async {
    await tester.tap(addSubfieldBtn.last);
    await tester.pump();
    expect(((tester.widget(subfieldDropdown0.last) as DropdownButton).value as Subfield).name, equals('Web Development'));
    await tester.tap(addSubfieldBtn.last);
    await tester.pump();
    expect(((tester.widget(subfieldDropdown1.last) as DropdownButton).value as Subfield).name, equals('Mobile Development'));
  }

  static Future<void> changeSubfieldTest(WidgetTester tester) async {
    await tester.tap(subfieldDropdown0.last);
    await tester.pump();
    await tester.tap(find.text('Game Development').last);
    await tester.pump();
    expect(((tester.widget(subfieldDropdown0.last) as DropdownButton).value as Subfield).name, equals('Game Development'));
  }

  static Future<void> deleteSubfieldTest(WidgetTester tester) async {     
    await tester.tap(deleteSubfieldBtn0.last);
    await tester.pump();
    expect(find.byType(SubfieldDropdown), findsNWidgets(1));
    await tester.tap(deleteSubfieldBtn0.last);
    await tester.pump();
    expect(find.byType(SubfieldDropdown), findsNWidgets(0));     
  }  

}