import 'package:get_it/get_it.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/services/defaults_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/download_service.dart';
import 'package:mwb_connect_app/core/services/translate_service.dart';
import 'package:mwb_connect_app/core/services/analytics_service.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/users_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/notifications_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/support_request_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/feedback_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/updates_view_model.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerSingletonAsync<LocalStorageService>(() async => LocalStorageService().init()); 
  locator.registerLazySingleton(() => DefaultsService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => DownloadService());
  locator.registerLazySingleton(() => TranslateService());
  locator.registerLazySingleton(() => AnalyticsService());
  locator.registerLazySingleton(() => Api());
  locator.registerLazySingleton(() => CommonViewModel());
  locator.registerLazySingleton(() => UsersViewModel());
  locator.registerLazySingleton(() => GoalsViewModel());
  locator.registerLazySingleton(() => StepsViewModel());
  locator.registerLazySingleton(() => QuizzesViewModel());
  locator.registerLazySingleton(() => NotificationsViewModel());
  locator.registerLazySingleton(() => SupportRequestViewModel());
  locator.registerLazySingleton(() => FeedbackViewModel());
  locator.registerLazySingleton(() => UpdatesViewModel());
}