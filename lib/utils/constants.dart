class AppConstants {
  static const String mixpanelToken = '81cc871cb3dbe7ba070c1fb7b523645c';
  static const List<String> daysOfWeekEng = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const String vowels = 'aeiouAEIOU';
  static const List<String> onboarding = [
    'mental_process_goal_steps_onboarding',
    'relaxation_method_onboarding',
    'super_focus_method_onboarding'
  ];
  static const Map<String, List<String>> tutorials = {
    'mental_process_goal_steps': ['main', 'ideas', 'energy', 'confidence', 'extra_benefits'],
    'relaxation_method': ['main', 'how_to_relax'],
    'super_focus_method': ['main', 'joyful_productivity', 'extra_energy']
  };
  static const bool notificationsEnabled = true;
  static const String notificationsTime = '21:00';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String dateFormat = 'MMM d, yyyy';
  static const String timeFormat = 'h:mma';
  static const String dayOfWeekFormat = 'EEEE';
  static const String dateFormatLesson = 'EEEE, MMM d';
  static const String timeFormatLesson = 'h:mm a';
  static const String meetingUrlType = 'Google Meet/Zoom';
  static const int minLessonsNumberRecurrence = 1;
  static const int maxLessonsNumberRecurrence = 10;
  static const int mentorWeeksTraining = 4;
  static const int studentWeeksTraining = 13;
  static const int studentQuizzes = 12;
  static const int availableMentorsResultsPerPage = 20;
}