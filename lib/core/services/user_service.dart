import 'package:quiver/strings.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/timezone_model.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';


class UserService {
  final ApiService _api = locator<ApiService>();
  final LocalStorageService _storageService = locator<LocalStorageService>();

  Future<void> setUserStorage({User? user}) async {
    if (user?.id != null) {
      _storageService.userId = user?.id;
      _storageService.userEmail = user?.email;
      if (isNotEmpty(user?.name)) {
        _storageService.userName = user?.name;
      }      
      if (user?.isMentor != null) {
        _storageService.isMentor = user?.isMentor;
        _storageService.fieldId = user?.field?.id;
        _storageService.fieldName = user?.field?.name;
        List<Subfield>? subfields = user?.field?.subfields;
        if (user?.isMentor == false && subfields != null && subfields.length > 0) {
          _storageService.subfieldId = subfields[0].id;
        }
      }        
      if (user?.registeredOn != null) {
        _storageService.registeredOn = user?.registeredOn.toString();
      }      
    }
  }

  Future<User> getUserDetails() async {
    Map<String, dynamic> response = await _api.getHTTP(url: '/user');
    User user = User.fromJson(response);
    return user;
  }

  Future<void> setUserDetails(User? user) async {
    _api.putHTTP(url: '/user', data: user?.toJson());
  }

  Future<void> setUserTimeZone(TimeZoneModel timeZone) async {
    _api.putHTTP(url: '/timezones', data: timeZone.toJson());
  }
  
  Future<void> deleteUser(User? user) async {
    _api.deleteHTTP(url: '/user');
  }

}