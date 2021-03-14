import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/profile_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ui/utils/firebase_auth_mocks.dart';

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

  group('Profile view model tests', () {
    final ProfileViewModel profileViewModel = locator<ProfileViewModel>();

    setUp(() async {
      profileViewModel.profile = Profile();
      profileViewModel.profile.user = User(
        name: 'Bob', 
        field: 'Graphic Design',
        subfields: [
          'User Interface',
          'Marketing & Advertising'
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
    test('profile name should be changed', () async {
      const String name = 'Alice';
      profileViewModel.setName(name);
      expect(identical(profileViewModel.profile.user.name, name), true);
      final User user = await profileViewModel.getUserDetails();
      expect(identical(user.name, name), true);
    });
    
    test('field should be changed', () async {
      const String field = 'Programming';
      profileViewModel.setField(field);
      expect(identical(profileViewModel.profile.user.field, field), true);
      expect(profileViewModel.profile.user.subfields.isEmpty, true);
      final User user = await profileViewModel.getUserDetails();
      expect(identical(user.field, field), true);
      expect(user.subfields.isEmpty, true);
    });
    
    test('selected field should match initial field', () {
      final Field field = profileViewModel.getSelectedField();
      expect(identical(field.name, 'Graphic Design'), true);
    });

    test('selected field should match default field', () {
      profileViewModel.setField('');
      final Field field = profileViewModel.getSelectedField();
      expect(identical(field.name, 'Programming'), true);
    });
    
    test('subfield should be changed', () async {
      const String subfield = 'Visual Identity';
      profileViewModel.setSubfield(subfield, 0);
      expect(identical(profileViewModel.profile.user.subfields[0], subfield), true);
      final User user = await profileViewModel.getUserDetails();
      expect(identical(user.subfields[0], subfield), true);
    });
    
    test('subfield should be added', () async {
      const String subfield = 'Visual Identity';
      profileViewModel.setSubfield(subfield, 2);
      expect(identical(profileViewModel.profile.user.subfields[2], subfield), true);
      final User user = await profileViewModel.getUserDetails();
      expect(identical(user.subfields[2], subfield), true);      
    });
    
    test('subfields should be filtered', () {
      final List<Subfield> subfields = profileViewModel.getSubfields(1);
      expect(identical(subfields[0].name, 'Visual Identity'), true);   
      expect(identical(subfields[1].name, 'Marketing & Advertising'), true);   
    });

    test('selected subfield should be correct', () async {
      final Subfield selectedSubfield = profileViewModel.getSelectedSubfield(1);
      expect(identical(selectedSubfield.name, 'Marketing & Advertising'), true);   
    });
    
    test('added default subfield should be correct', () async {
      profileViewModel.addSubfield();
      expect(identical(profileViewModel.profile.user.subfields[2], 'Visual Identity'), true);   
    });
    
    test('subfields list should be correct after delete subfield', () {
      profileViewModel.deleteSubfield(1);
      final List<String> subfields = profileViewModel.profile.user.subfields;
      expect(identical(subfields[0], 'User Interface'), true);   
      expect(subfields.asMap().containsKey(1), false);   
    });

  });
}