import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/firebase_auth_mocks.dart';
import '../../utils/easy_localization_loader.dart';

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
  String jsonFile = await rootBundle.loadString('assets/i18n/en-US.json');

  group('Profile view model tests', () {
    final EasyLocalizationLoader easyLocalizationLoader = EasyLocalizationLoader();
    final ProfileViewModel profileViewModel = locator<ProfileViewModel>();

    setUp(() async {
      final EasyLocalizationController easyLocalizationController = easyLocalizationLoader.createEasyLocalizationController(jsonFile: jsonFile);
      await easyLocalizationController.loadTranslations();
      Localization.load(Locale('en', 'US'), translations: easyLocalizationController.translations);

      profileViewModel.profile = Profile();
      profileViewModel.profile.user = User(
        name: 'Bob', 
        field: 'Graphic Design',
        subfields: [
          'User Interface',
          'Marketing & Advertising'
        ],
        isAvailable: true,
        availabilities: [
          Availability(
            dayOfWeek: 'Saturday',
            time: Time(from: '10am', to: '2pm')
          )
        ]
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

    test('Profile name should be changed', () async {
      const String name = 'Alice';
      profileViewModel.setName(name);
      expect(profileViewModel.profile.user.name, name);
      final User user = await profileViewModel.getUserDetails();
      expect(user.name, name);
    });
    
    test('Field should be changed', () async {
      const String field = 'Programming';
      profileViewModel.setField(field);
      expect(profileViewModel.profile.user.field, field);
      expect(profileViewModel.profile.user.subfields.isEmpty, true);
      final User user = await profileViewModel.getUserDetails();
      expect(user.field, field);
      expect(user.subfields.isEmpty, true);
    });
    
    test('Selected field should match initial field', () {
      final Field field = profileViewModel.getSelectedField();
      expect(field.name, 'Graphic Design');
    });

    test('Selected field should match default field', () {
      profileViewModel.setField('');
      final Field field = profileViewModel.getSelectedField();
      expect(field.name, 'Programming');
    });
    
    test('Subfield should be changed', () async {
      const String subfield = 'Visual Identity';
      profileViewModel.setSubfield(subfield, 0);
      expect(profileViewModel.profile.user.subfields[0], subfield);
      final User user = await profileViewModel.getUserDetails();
      expect(user.subfields[0], subfield);
    });
    
    test('Subfield should be added', () async {
      const String subfield = 'Visual Identity';
      profileViewModel.setSubfield(subfield, 2);
      expect(profileViewModel.profile.user.subfields[2], subfield);
      final User user = await profileViewModel.getUserDetails();
      expect(user.subfields[2], subfield);      
    });
    
    test('Subfields should be filtered', () {
      final List<Subfield> subfields = profileViewModel.getSubfields(1);
      expect(subfields[0].name, 'Visual Identity');   
      expect(subfields[1].name, 'Marketing & Advertising');   
    });

    test('Selected subfield should be correct', () async {
      final Subfield selectedSubfield = profileViewModel.getSelectedSubfield(1);
      expect(selectedSubfield.name, 'Marketing & Advertising');   
    });
    
    test('Added default subfield should be correct', () async {
      profileViewModel.addSubfield();
      expect(profileViewModel.profile.user.subfields[2], 'Visual Identity');   
    });
    
    test('Subfields list should be correct after delete subfield', () {
      profileViewModel.deleteSubfield(1);
      final List<String> subfields = profileViewModel.profile.user.subfields;
      expect(subfields[0], 'User Interface');   
      expect(subfields.asMap().containsKey(1), false);   
    });

    test('User availability should be set correctly', () {
      profileViewModel.setIsAvailable(false);
      expect(profileViewModel.profile.user.isAvailable, false);
      profileViewModel.setIsAvailable(true);
      expect(profileViewModel.profile.user.isAvailable, true);         
    });

    test('New availability should be added', () {
      Availability availability = Availability(
        dayOfWeek: 'Wednesday',
        time: Time(from: '8pm', to: '10pm')
      );
      profileViewModel.addAvailability(availability);
      List<Availability> availabilities = profileViewModel.profile.user.availabilities;
      expect(availabilities[0].dayOfWeek, 'Wednesday');
      expect(availabilities[0].time.from, '8pm');
      expect(availabilities[0].time.to, '10pm');
      expect(availabilities[1].dayOfWeek, 'Saturday');
      expect(availabilities[1].time.from, '10am');
      expect(availabilities[1].time.to, '2pm');     
    });

    test('Availabilities should be merged correctly when adding new availability', () {
      Availability availability1 = Availability(
        dayOfWeek: 'Saturday',
        time: Time(from: '5pm', to: '8pm')
      );
      Availability availability2 = Availability(
        dayOfWeek: 'Saturday',
        time: Time(from: '11am', to: '6pm')
      );
      profileViewModel.addAvailability(availability1);
      profileViewModel.addAvailability(availability2);
      List<Availability> availabilities = profileViewModel.profile.user.availabilities;
      expect(availabilities[0].dayOfWeek, 'Saturday');
      expect(availabilities[0].time.from, '10am');
      expect(availabilities[0].time.to, '8pm');      
    });
    
    test('Availability should be updated', () {
      List<Availability> availabilities = profileViewModel.profile.user.availabilities;
      Availability newAvailability = Availability(
        dayOfWeek: 'Thursday',
        time: Time(from: '7pm', to: '10pm')
      );
      profileViewModel.updateAvailability(0, newAvailability);
      expect(availabilities[0].dayOfWeek, 'Thursday');
      expect(availabilities[0].time.from, '7pm');
      expect(availabilities[0].time.to, '10pm');
    });  

    test('Availabilities should be merged correctly when updating availability', () {
      Availability availability = Availability(
        dayOfWeek: 'Saturday',
        time: Time(from: '4pm', to: '7pm')
      );
      profileViewModel.addAvailability(availability);
      availability = Availability(
        dayOfWeek: 'Saturday',
        time: Time(from: '1pm', to: '5pm')
      );
      profileViewModel.updateAvailability(1, availability);
      List<Availability> availabilities = profileViewModel.profile.user.availabilities;
      expect(availabilities[0].dayOfWeek, 'Saturday');
      expect(availabilities[0].time.from, '10am');
      expect(availabilities[0].time.to, '5pm');      
    });      

  });
}