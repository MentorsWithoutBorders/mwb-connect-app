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
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/widget_loader.dart';

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

  group('Profile view tests:', () {
    final ProfileViewModel profileViewModel = locator<ProfileViewModel>();
    final Profile profile = Profile();
    final WidgetLoader widgetLoader = WidgetLoader();
    final Widget profileWidget = widgetLoader.createWidget(widget: ProfileView(), jsonFile: jsonFile);

    setUp(() async {
      final EasyLocalizationController easyLocalizationController = widgetLoader.createEasyLocalizationController(jsonFile: jsonFile);
      await easyLocalizationController.loadTranslations();
      Localization.load(Locale('en', 'US'), translations: easyLocalizationController.translations);

      profile.user = User(
        name: 'Bob',
        field: 'Programming',
        subfields: [
          Subfield(
            name: 'Web Development',
            skills: [
              'HTML',
              'CSS'
            ]
          ),
          Subfield(
            name: 'Mobile Development',
            skills: []
          )
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
        ],
        lessonsAvailability: LessonsAvailability(
          minInterval: 2,
          minIntervalUnit: 'week'
        )
      );
      final List<Field> fields = [
        Field(
          name: 'Programming',
          subfields: [
            Subfield(
              name: 'Web Development', 
              skills: [
                'HTML',
                'CSS',
                'JavaScript'
              ]
            ),
            Subfield(name: 'Mobile Development', skills: []),
            Subfield(name: 'Game Development', skills: []),
          ]
        ),
        Field(
          name: 'Graphic Design',
          subfields: [
            Subfield(name: 'Visual Identity', skills: []),
            Subfield(name: 'Marketing & Advertising', skills: []),
            Subfield(name: 'User Interface', skills: []),
          ]
        ),
      ];
      profileViewModel.setFields(fields);
      profileViewModel.profile = profile;
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
        expect(find.byKey(const Key(AppKeys.deleteSubfieldBtn + '0')), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.deleteSubfieldBtn + '1')), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.skillTag + '0')), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.skillTag + '1')), findsOneWidget);        
        expect(find.byKey(const Key(AppKeys.deleteSkillBtn + '0')), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.deleteSkillBtn + '1')), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.addSkillsField)), findsNWidgets(2));
        expect(find.text('Add subfield'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.addSubfieldBtn)), findsOneWidget);
        await tester.drag(find.byKey(Key(AppKeys.profileListView)), const Offset(0.0, -500));
        await tester.pump();        
        expect(find.text('Availability'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.currentlyAvailableRadio)), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.currentlyAvailableText)), findsOneWidget);
        expect(find.text('I\'m currently available'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.availableFromRadio)), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.availableFromText)), findsOneWidget);
        expect(find.text('I\'m available starting from:'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.availableFromDate)), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.editCalendarIcon)), findsOneWidget);
        expect(find.text('Available days/times'), findsOneWidget);
        DateTime now = DateTime.now();
        expect(find.text('All times are in ' + now.timeZoneName + ' time zone.'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.availabilityItem + '0')).last, findsOneWidget);
        expect(find.byKey(const Key(AppKeys.availabilityItem + '1')).last, findsOneWidget);
        expect(find.byKey(const Key(AppKeys.editAvailabilityIcon + '0')).last, findsOneWidget);
        expect(find.byKey(const Key(AppKeys.editAvailabilityIcon + '1')).last, findsOneWidget);
        expect(find.byKey(const Key(AppKeys.deleteAvailabilityBtn + '0')), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.deleteAvailabilityBtn + '1')), findsOneWidget);
        expect(find.text('Add availability'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.addAvailabilityBtn)), findsOneWidget);
        expect(find.text('Lessons'), findsOneWidget);
        expect(find.text('Minimum interval between lessons:'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.minIntervalDropdown)).last, findsOneWidget);
        expect(find.byKey(const Key(AppKeys.minIntervalUnitDropdown)).last, findsOneWidget);
        debugDefaultTargetPlatformOverride = null;
      });
    });      

    testWidgets('Profile widgets show up for student test', (WidgetTester tester) async {
      await tester.runAsync(() async {
        profile.user.isMentor = false;
        profileViewModel.setUserDetails(profile.user); 
        await tester.pumpWidget(profileWidget);
        await tester.pumpAndSettle();
        expect(find.text('Name'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.nameField)).last, findsOneWidget);
        expect(find.text('Availability'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.availabilityItem + '0')).last, findsOneWidget);
        expect(find.byKey(const Key(AppKeys.availabilityItem + '1')).last, findsOneWidget);
        expect(find.byKey(const Key(AppKeys.editAvailabilityIcon + '0')).last, findsOneWidget);
        expect(find.byKey(const Key(AppKeys.editAvailabilityIcon + '1')).last, findsOneWidget);        
        expect(find.byKey(const Key(AppKeys.deleteAvailabilityBtn + '0')), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.deleteAvailabilityBtn + '1')), findsOneWidget);
        expect(find.text('Add availability'), findsOneWidget);
        expect(find.byKey(const Key(AppKeys.addAvailabilityBtn)), findsOneWidget);
      });
    });
  });
}