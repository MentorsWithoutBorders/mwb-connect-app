import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/widget_loader.dart';
import '../../../utils/firebase_auth_mocks.dart';

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

  group('Profile view tests:', () {
    final ProfileViewModel profileViewModel = locator<ProfileViewModel>();
    final Profile profile = Profile();
    final WidgetLoader widgetLoader = WidgetLoader();
    final Widget profileWidget = widgetLoader.createWidget(widget: ProfileView(isMentor: true), jsonFile: jsonFile);

    setUp(() async {
      final EasyLocalizationController easyLocalizationController = widgetLoader.createEasyLocalizationController(jsonFile: jsonFile);
      await easyLocalizationController.loadTranslations();
      Localization.load(Locale('en', 'US'), translations: easyLocalizationController.translations);
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      profile.user = User(
        name: 'Bob',
        field: 'Programming',
        subfields: [
          'Web Development',
          'Mobile Development'
        ],
        isAvailable: true,
        availabilities: [
          Availability(
            dayOfWeek: 'Wednesday',
            time: Time(from: '8pm', to: '10pm')
          ),
          Availability(
            dayOfWeek: 'Saturday',
            time: Time(from: '10am', to: '2pm')
          )
        ]        
      );
      final List<Field> fields = [
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
      profileViewModel.setFields(fields);
    });  

    testWidgets('Profile widgets show up for mentor test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        profile.user.isMentor = true;
        profileViewModel.setUserDetails(profile.user);        
        await tester.pumpWidget(profileWidget);
        await tester.pumpAndSettle();
        expect(find.text('Name'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.nameField)).last, findsOneWidget);
        expect(find.text('Field'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.fieldDropdown)).last, findsOneWidget);
        expect(find.text('Subfields'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.subfieldDropdown + '0')).last, findsOneWidget);
        expect(find.byKey(const Key(AppKeys.subfieldDropdown + '1')).last, findsOneWidget);        
        expect(find.byKey(const Key(AppKeys.deleteSubfieldBtn + '0')).last, findsOneWidget);
        expect(find.byKey(const Key(AppKeys.deleteSubfieldBtn + '1')).last, findsOneWidget);
        expect(find.text('Add subfield'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.addSubfieldBtn)).last, findsOneWidget);
        expect(find.text('I\'m currently available'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.isAvailableSwitchAndroid)).last, findsOneWidget);
        expect(find.text('Availability'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.availabilityItem + '0')).last, findsOneWidget);
        expect(find.byKey(const Key(AppKeys.availabilityItem + '1')).last, findsOneWidget);
        expect(find.byKey(const Key(AppKeys.deleteAvailabilityBtn + '0')).last, findsOneWidget);
        expect(find.byKey(const Key(AppKeys.deleteAvailabilityBtn + '1')).last, findsOneWidget);
        expect(find.text('Add availability'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.addAvailabilityBtn)).last, findsOneWidget);        
        debugDefaultTargetPlatformOverride = null;
      });
    });
  });
}