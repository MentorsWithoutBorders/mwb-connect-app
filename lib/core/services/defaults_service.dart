import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/utils/constants.dart';

class DefaultsService {

  void setDefaults() {
    var storageService = locator<LocalStorageService>();
    if (storageService.onboarding == null ) {
      storageService.onboarding = AppConstants.onboarding;
    }
    if (storageService.tutorials == null ) {
      storageService.tutorials = AppConstants.tutorials;
    }
    if (storageService.quizzesCount == null ) {
      storageService.quizzesCount = AppConstants.quizzesCount;
    }
    if (storageService.quizzesRounds == null ) {
      storageService.quizzesRounds = AppConstants.quizzesRounds;
    }
    if (storageService.timeBetweenQuizzesRounds == null ) {
      storageService.timeBetweenQuizzesRounds = AppConstants.timeBetweenQuizzesRounds;
    }
    if (storageService.notificationsEnabled == null ) {
      storageService.notificationsEnabled = AppConstants.notificationsEnabled;
    }
    if (storageService.notificationsTime == null ) {
      storageService.notificationsTime = AppConstants.notificationsTime;
    }    
  }

}