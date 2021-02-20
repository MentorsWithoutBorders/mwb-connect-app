import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import '../../../ui/utils/widget_loader.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/field_dropdown_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/widgets/subfield_dropdown_widget.dart';

class ProfileViewTest extends StatelessWidget {
  final Widget widget;

  ProfileViewTest({@required this.widget});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: locator<ProfileViewModel>()),
      ],
      child: MaterialApp(
        locale: EasyLocalization.of(context).locale,
        supportedLocales: EasyLocalization.of(context).supportedLocales,
        localizationsDelegates: EasyLocalization.of(context).delegates,
        theme: ThemeData(),
        home: widget
      )
    );
  }
}

void main() async {
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();  
  TestWidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  final getIt = GetIt.instance;
  await getIt.allReady();
  LocalStorageService storageService = locator<LocalStorageService>();
  storageService.userId = 'test_user';

  group('Profile view tests', () {
    var profileViewModel = locator<ProfileViewModel>();
    String jsonFile;

    setUp(() async {
      profileViewModel.profile = Profile();
      profileViewModel.profile.user = User(
        name: 'Bob',
        field: 'Programming',
        subfields: [
          'Web Development',
          'Mobile Development'
        ]
      );
      List<Field> fields = [
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
      await profileViewModel.setFields(fields);
      jsonFile = await rootBundle.loadString('assets/i18n/en-US.json');
    });  

    testWidgets('testing if all profile widgets show up for mentor', (tester) async {
      await tester.runAsync(() async {
        var widgetLoader = WidgetLoader();
        profileViewModel.profile.user.isMentor = true;
        await profileViewModel.setUserDetails(profileViewModel.profile.user);        
        await tester.pumpWidget(
          widgetLoader.createLocalizedWidgetForTesting(
            child: ProfileViewTest(widget: ProfileView(isMentor: true)), 
            jsonFile: jsonFile
          )
        );
        await tester.pumpAndSettle();
        expect(find.text('Name'), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.byType(DropdownButtonHideUnderline), findsNWidgets(3));
        expect(find.text('Field'), findsOneWidget);
        expect(find.byType(FieldDropdown), findsOneWidget);
        expect(find.text('Subfields'), findsOneWidget);
        expect(find.byType(SubfieldDropdown), findsNWidgets(2));
        expect(find.text('Add subfield'), findsOneWidget);
        expect(find.byType(Image), findsNWidgets(2));        
        expect(find.byType(RaisedButton), findsOneWidget);
      });
    });       

  });
}