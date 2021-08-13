import 'package:get_it/get_it.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';
import 'package:mwb_connect_app/core/services/push_notifications_service.dart';
import 'package:mwb_connect_app/core/services/navigation_service.dart';
import 'package:mwb_connect_app/core/services/defaults_service.dart';
import 'package:mwb_connect_app/core/services/api_service.dart';
import 'package:mwb_connect_app/core/services/authentication_service.dart';
import 'package:mwb_connect_app/core/services/forgot_password_service.dart';
import 'package:mwb_connect_app/core/services/profile_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';
import 'package:mwb_connect_app/core/services/goals_service.dart';
import 'package:mwb_connect_app/core/services/steps_service.dart';
import 'package:mwb_connect_app/core/services/quizzes_service.dart';
import 'package:mwb_connect_app/core/services/connect_with_mentor_service.dart';
import 'package:mwb_connect_app/core/services/lesson_request_service.dart';
import 'package:mwb_connect_app/core/services/notifications_service.dart';
import 'package:mwb_connect_app/core/services/support_request_service.dart';
import 'package:mwb_connect_app/core/services/download_service.dart';
import 'package:mwb_connect_app/core/services/analytics_service.dart';
import 'package:mwb_connect_app/core/services/update_app_service.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/root_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/login_signup_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/forgot_password_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/notifications_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/support_request_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/update_app_view_model.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerSingletonAsync<LocalStorageService>(() async => LocalStorageService().init()); 
  locator.registerLazySingleton(() => PushNotificationsService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DefaultsService());
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => ForgotPasswordService());
  locator.registerLazySingleton(() => ProfileService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => GoalsService());
  locator.registerLazySingleton(() => StepsService());
  locator.registerLazySingleton(() => QuizzesService());
  locator.registerLazySingleton(() => ConnectWithMentorService());
  locator.registerLazySingleton(() => LessonRequestService());
  locator.registerLazySingleton(() => NotificationsService());
  locator.registerLazySingleton(() => SupportRequestService());
  locator.registerLazySingleton(() => DownloadService());
  locator.registerLazySingleton(() => AnalyticsService());
  locator.registerLazySingleton(() => UpdateAppService());
  locator.registerLazySingleton(() => CommonViewModel());
  locator.registerLazySingleton(() => RootViewModel());
  locator.registerLazySingleton(() => LoginSignupViewModel());
  locator.registerLazySingleton(() => ForgotPasswordViewModel());
  locator.registerLazySingleton(() => ProfileViewModel());
  locator.registerLazySingleton(() => ConnectWithMentorViewModel());
  locator.registerLazySingleton(() => LessonRequestViewModel());
  locator.registerLazySingleton(() => GoalsViewModel());
  locator.registerLazySingleton(() => StepsViewModel());
  locator.registerLazySingleton(() => QuizzesViewModel());
  locator.registerLazySingleton(() => NotificationsViewModel());
  locator.registerLazySingleton(() => SupportRequestViewModel());
  locator.registerLazySingleton(() => UpdateAppViewModel());
}