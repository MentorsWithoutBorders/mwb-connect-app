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
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/field_dropdown_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/subfield_dropdown_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/subfields_widget.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';

void main() async {
  SharedPreferences.setMockInitialValues({});
  TestWidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  final getIt = GetIt.instance;
  await getIt.allReady();
  LocalStorageService storageService = locator<LocalStorageService>();
  storageService.userId = 'test_user';  

  group('Subfield dropdown widget tests:', () {
    var profileViewModel = locator<ProfileViewModel>();
    String jsonFile;

    Widget createSubfieldsWidget() {
      var widgetLoader = WidgetLoader();
      return widgetLoader.createLocalizedWidgetForTesting(
        child: TestApp(
          widget: Scaffold(
            body: Wrap(
              children: [
                FieldDropdown(),
                Subfields()
              ],
            )
          )
        ),
        jsonFile: jsonFile
      );
    }    

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
      jsonFile = await rootBundle.loadString('assets/i18n/en-US.json');
    });

    testWidgets('Subfield dropdowns show up test', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createSubfieldsWidget());
        await tester.pump();
        expect(find.text('Subfields'), findsOneWidget);
      });
    });

    testWidgets('Add subfield test', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createSubfieldsWidget());
        await tester.pump();
        await tester.tap(find.byKey(Key(AppKeys.addSubfieldBtn)).last);
        await tester.pump();
        expect((((tester.widget(find.byKey(Key(AppKeys.subfieldDropdown + '0')).last) as DropdownButton).value) as Subfield).name, equals('Web Development'));
        await tester.tap(find.byKey(Key(AppKeys.addSubfieldBtn)).last);
        await tester.pump();
        expect((((tester.widget(find.byKey(Key(AppKeys.subfieldDropdown + '1')).last) as DropdownButton).value) as Subfield).name, equals('Mobile Development'));        
      });
    });

    testWidgets('Change subfield test', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createSubfieldsWidget());
        await tester.pump();
        await tester.tap(find.byKey(Key(AppKeys.addSubfieldBtn)).last);
        await tester.pump();
        await tester.tap(find.byKey(Key(AppKeys.subfieldDropdown + '0')).last);
        await tester.pump();
        await tester.tap(find.text('Game Development').last);
        await tester.pump();
        expect((((tester.widget(find.byKey(Key(AppKeys.subfieldDropdown + '0')).last) as DropdownButton).value) as Subfield).name, equals('Game Development'));
      });
    });
    
    testWidgets('Delete subfields test', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(createSubfieldsWidget());
        await tester.pump();
        await tester.tap(find.byKey(Key(AppKeys.addSubfieldBtn)).last);
        await tester.pump();
        await tester.tap(find.byKey(Key(AppKeys.addSubfieldBtn)).last);
        await tester.pump();        
        await tester.tap(find.byKey(Key(AppKeys.deleteSubfieldBtn + '0')).last);
        await tester.pump();
        expect(find.byType(SubfieldDropdown), findsNWidgets(1));
        await tester.tap(find.byKey(Key(AppKeys.deleteSubfieldBtn + '0')).last);
        await tester.pump();
        expect(find.byType(SubfieldDropdown), findsNWidgets(0));        
      });
    });      
  });
}