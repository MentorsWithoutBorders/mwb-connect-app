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
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/widget_loader.dart';

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
  String jsonFile = await rootBundle.loadString('assets/i18n/en-US.json');

  group('Profile view model tests', () {
    final WidgetLoader widgetLoader = WidgetLoader();
    final ProfileViewModel profileViewModel = locator<ProfileViewModel>();

    setUp(() async {
      final EasyLocalizationController easyLocalizationController = widgetLoader.createEasyLocalizationController(jsonFile: jsonFile);
      await easyLocalizationController.loadTranslations();
      Localization.load(Locale('en', 'US'), translations: easyLocalizationController.translations);

      profileViewModel.profile = Profile();
      profileViewModel.user = User(
        name: 'Bob', 
        field: 'Graphic Design',
        subfields: [
          Subfield(
            name: 'User Interface',
            skills: []
          ),
          Subfield(
            name: 'Marketing & Advertising',
            skills: []
          )
        ],
        isAvailable: true,
        availabilities: [
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
            ),
            Subfield(name: 'Mobile Development'),
            Subfield(name: 'Game Development'),
          ]
        ),
        Field(
          name: 'Graphic Design',
          subfields: [
            Subfield(
              name: 'User Interface',
              skills: [
                'Adobe Photoshop',
                'Adobe Illustrator',
                'Sketch'
              ]
            ),
            Subfield(name: 'Visual Identity'),
            Subfield(name: 'Marketing & Advertising')
          ]
        ),
      ];
    });  

    test('Profile name should be changed', () async {
      const String name = 'Alice';
      profileViewModel.setName(name);
      expect(profileViewModel.user.name, name);
      final User user = await profileViewModel.getUserDetails();
      expect(user.name, name);
    });
    
    test('Field should be changed', () async {
      const String field = 'Programming';
      profileViewModel.setField(field);
      expect(profileViewModel.user.field, field);
      expect(profileViewModel.user.subfields.isEmpty, true);
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
      Subfield subfield = Subfield(name: 'Visual Identity');
      profileViewModel.setSubfield(subfield, 0);
      expect(profileViewModel.user.subfields[0].name, subfield.name);
      final User user = await profileViewModel.getUserDetails();
      expect(user.subfields[0].name, subfield.name);
    });
    
    test('Subfield should be added', () async {
      Subfield subfield = Subfield(name: 'Visual Identity');
      profileViewModel.setSubfield(subfield, 2);
      expect(profileViewModel.user.subfields[2].name, subfield.name);
      final User user = await profileViewModel.getUserDetails();
      expect(user.subfields[2].name, subfield.name);
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
      expect(profileViewModel.user.subfields[2].name, 'Visual Identity');   
    });
    
    test('Subfields list should be correct after delete subfield', () {
      profileViewModel.deleteSubfield(1);
      final List<Subfield> subfields = profileViewModel.user.subfields;
      expect(subfields[0].name, 'User Interface');   
      expect(subfields.asMap().containsKey(1), false);   
    });

    test('Scroll offset should be set correctly', () {
      profileViewModel.setScrollOffset(250, 640, 60);
      expect(profileViewModel.scrollOffset, 100);
      profileViewModel.setScrollOffset(150, 640, 60);
      expect(profileViewModel.scrollOffset, -90);
      profileViewModel.setScrollOffset(220, 640, 60);
      expect(profileViewModel.scrollOffset, -90);
    });
    
    test('Skills hint should be set correctly', () {
      String hint = profileViewModel.getSkillHintText(0);
      expect(hint, 'Add skills (e.g. Adobe Photoshop, Adobe Illustrator, Sketch, etc.)');
    });
    
    test('Skill suggestions list should be set correctly', () {
      List<String> skillSugestions = profileViewModel.getSkillSuggestions('ado', 0);
      expect(skillSugestions, ['Adobe Photoshop', 'Adobe Illustrator']);
      skillSugestions = profileViewModel.getSkillSuggestions('abd', 0);
      expect(skillSugestions, []);      
    });
    
    test('Skill should be added', () {
      profileViewModel.addSkill('Adobe Photoshop', 0);
      List<String> userSkills = profileViewModel.user.subfields[0].skills;
      profileViewModel.addSkill('Sketch', 0);
      expect(userSkills, ['Adobe Photoshop', 'Sketch']);
      profileViewModel.addSkill('Adobe Photoshop', 0);
      expect(userSkills, ['Adobe Photoshop', 'Sketch']);      
    });

    test('Skill should be deleted', () {
      profileViewModel.addSkill('Adobe Photoshop', 0);
      profileViewModel.deleteSkill('Adobe Photoshop', 0);
      List<String> userSkills = profileViewModel.user.subfields[0].skills;
      expect(userSkills, []);
    });      

    test('User availability should be set correctly', () {
      profileViewModel.setIsAvailable(false);
      expect(profileViewModel.user.isAvailable, false);
      profileViewModel.setIsAvailable(true);
      expect(profileViewModel.user.isAvailable, true);         
    });

    test('User available from date should be set correctly', () {
      profileViewModel.setAvailableFrom(DateTime.now());
      expect(profileViewModel.user.availableFrom.hour, DateTime.now().hour);
      expect(profileViewModel.user.availableFrom.minute, DateTime.now().minute);
      expect(profileViewModel.user.availableFrom.second, DateTime.now().second);
    });    

    test('New availability should be added', () {
      Availability availability = Availability(
        dayOfWeek: 'Wednesday',
        time: Time(from: '8pm', to: '10pm')
      );
      profileViewModel.addAvailability(availability);
      List<Availability> availabilities = profileViewModel.user.availabilities;
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
      List<Availability> availabilities = profileViewModel.user.availabilities;
      expect(availabilities[0].dayOfWeek, 'Saturday');
      expect(availabilities[0].time.from, '10am');
      expect(availabilities[0].time.to, '8pm');      
    });
    
    test('Availability should be updated', () {
      List<Availability> availabilities = profileViewModel.user.availabilities;
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
      List<Availability> availabilities = profileViewModel.user.availabilities;
      expect(availabilities[0].dayOfWeek, 'Saturday');
      expect(availabilities[0].time.from, '10am');
      expect(availabilities[0].time.to, '5pm');      
    });
    
    test('Availability should be valid', () {
      Availability availability = Availability(
        dayOfWeek: 'Monday',
        time: Time(from: '8pm', to: '10pm')
      );
      expect(profileViewModel.isAvailabilityValid(availability), true);
      availability = Availability(
        dayOfWeek: 'Saturday',
        time: Time(from: '10am', to: '10am')
      );
      expect(profileViewModel.isAvailabilityValid(availability), false);       
      availability = Availability(
        dayOfWeek: 'Thursday',
        time: Time(from: '5pm', to: '3pm')
      );
      expect(profileViewModel.isAvailabilityValid(availability), false);    
    });
    
    test('Availability should be deleted', () {
      Availability availability = Availability(
        dayOfWeek: 'Thursday',
        time: Time(from: '7pm', to: '10pm')
      );
      profileViewModel.addAvailability(availability);
      profileViewModel.deleteAvailability(0);
      List<Availability> availabilities = profileViewModel.user.availabilities;
      expect(availabilities[0].dayOfWeek, 'Saturday');
      expect(availabilities[0].time.from, '10am');
      expect(availabilities[0].time.to, '2pm');
    });

    test('Lessons availability should be updated', () {
      LessonsAvailability lessonsAvailability = LessonsAvailability(
        minInterval: 4,
        minIntervalUnit: 'month'
      );
      profileViewModel.updateLessonsAvailability(lessonsAvailability);
      lessonsAvailability = profileViewModel.user.lessonsAvailability;      
      expect(lessonsAvailability.minInterval, 4);
      expect(lessonsAvailability.minIntervalUnit, 'month');
    });

    test('Period unit plural should be correct', () {
      String periodUnit = profileViewModel.getPeriodUnitPlural('month', 3);      
      expect(periodUnit, 'months');
      periodUnit = profileViewModel.getPeriodUnitPlural('week', 1);
      expect(periodUnit, 'week');
    });
    
    test('Period unit singular should be correct', () {
      String periodUnit = profileViewModel.getPeriodUnitSingular('months', 3);      
      expect(periodUnit, 'month');
      periodUnit = profileViewModel.getPeriodUnitSingular('week', 1);
      expect(periodUnit, 'week');
    });      

  });
}