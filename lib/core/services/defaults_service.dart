import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/utils/constants.dart';

class DefaultsService {
  void setDefaults() {
    final LocalStorageService storageService = locator<LocalStorageService>();
    storageService.tutorials = AppConstants.tutorials;
    storageService.quizzesStudentWeeklyCount ??= AppConstants.quizzesStudentWeeklyCount;
    storageService.quizzesMentorWeeklyCount ??= AppConstants.quizzesMentorWeeklyCount;
  }

}