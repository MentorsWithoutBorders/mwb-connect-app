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
import 'package:mwb_connect_app/core/services/mentor_course/mentor_course_api_service.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentor_course_texts_service.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentor_course_utils_service.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentors_waiting_requests_api_service.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentors_waiting_requests_utils_service.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentors_waiting_requests_texts_service.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_api_service.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_texts_service.dart';
import 'package:mwb_connect_app/core/services/student_course/student_course_utils_service.dart';
import 'package:mwb_connect_app/core/services/student_course/available_courses_api_service.dart';
import 'package:mwb_connect_app/core/services/student_course/available_courses_texts_service.dart';
import 'package:mwb_connect_app/core/services/student_course/available_courses_utils_service.dart';
import 'package:mwb_connect_app/core/services/connect_with_mentor_service.dart';
import 'package:mwb_connect_app/core/services/available_mentors_service.dart';
import 'package:mwb_connect_app/core/services/fields_goals_service.dart';
import 'package:mwb_connect_app/core/services/lesson_request_service.dart';
import 'package:mwb_connect_app/core/services/in_app_messages_service.dart';
import 'package:mwb_connect_app/core/services/notifications_service.dart';
import 'package:mwb_connect_app/core/services/support_request_service.dart';
import 'package:mwb_connect_app/core/services/download_service.dart';
import 'package:mwb_connect_app/core/services/analytics_service.dart';
import 'package:mwb_connect_app/core/services/update_app_service.dart';
import 'package:mwb_connect_app/core/services/app_flags_service.dart';
import 'package:mwb_connect_app/core/services/logger_service.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/root_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/login_signup_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/forgot_password_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/profile_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course/mentor_course_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course/mentors_waiting_requests_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/student_course/student_course_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/student_course/available_courses_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/goals_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/quizzes_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/in_app_messages_view_model.dart';
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
  locator.registerLazySingleton(() => MentorCourseApiService());
  locator.registerLazySingleton(() => MentorCourseTextsService());
  locator.registerLazySingleton(() => MentorCourseUtilsService());
  locator.registerLazySingleton(() => StudentCourseApiService());
  locator.registerLazySingleton(() => StudentCourseTextsService());
  locator.registerLazySingleton(() => StudentCourseUtilsService());
  locator.registerLazySingleton(() => AvailableCoursesApiService());
  locator.registerLazySingleton(() => AvailableCoursesTextsService());
  locator.registerLazySingleton(() => AvailableCoursesUtilsService());
  locator.registerLazySingleton(() => MentorsWaitingRequestsApiService());
  locator.registerLazySingleton(() => MentorsWaitingRequestsUtilsService());
  locator.registerLazySingleton(() => MentorsWaitingRequestsTextsService());
  locator.registerLazySingleton(() => ConnectWithMentorService());
  locator.registerLazySingleton(() => AvailableMentorsService());
  locator.registerLazySingleton(() => FieldsGoalsService());
  locator.registerLazySingleton(() => LessonRequestService());
  locator.registerLazySingleton(() => InAppMessagesService());
  locator.registerLazySingleton(() => NotificationsService());
  locator.registerLazySingleton(() => SupportRequestService());
  locator.registerLazySingleton(() => AppFlagsService());
  locator.registerLazySingleton(() => DownloadService());
  locator.registerLazySingleton(() => AnalyticsService());
  locator.registerLazySingleton(() => UpdateAppService());
  locator.registerLazySingleton(() => LoggerService());
  locator.registerLazySingleton(() => CommonViewModel());
  locator.registerLazySingleton(() => RootViewModel());
  locator.registerLazySingleton(() => LoginSignupViewModel());
  locator.registerLazySingleton(() => ForgotPasswordViewModel());
  locator.registerLazySingleton(() => ProfileViewModel());
  locator.registerLazySingleton(() => MentorCourseViewModel());
  locator.registerLazySingleton(() => StudentCourseViewModel());
  locator.registerLazySingleton(() => AvailableCoursesViewModel());
  locator.registerLazySingleton(() => MentorsWaitingRequestsViewModel());
  locator.registerLazySingleton(() => ConnectWithMentorViewModel());
  locator.registerLazySingleton(() => AvailableMentorsViewModel());
  locator.registerLazySingleton(() => LessonRequestViewModel());
  locator.registerLazySingleton(() => GoalsViewModel());
  locator.registerLazySingleton(() => StepsViewModel());
  locator.registerLazySingleton(() => QuizzesViewModel());
  locator.registerLazySingleton(() => InAppMessagesViewModel());
  locator.registerLazySingleton(() => NotificationsViewModel());
  locator.registerLazySingleton(() => SupportRequestViewModel());
  locator.registerLazySingleton(() => UpdateAppViewModel());
}