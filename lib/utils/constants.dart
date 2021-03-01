class AppConstants {
  static const mixpanelToken = '81cc871cb3dbe7ba070c1fb7b523645c';
  static const List<String> onboarding = [
    'mental_process_goal_steps_onboarding',
    'relaxation_method_onboarding',
    'super_focus_method_onboarding'
  ];
  static const Map<String, List<String>> tutorials = {
    'mental_process_goal_steps': ['main', 'ideas', 'energy', 'confidence', 'extra_benefits'],
    'relaxation_method': ['main', 'how_to_relax', 'why_count_down', 'interruptions', 'fast_slow_relaxation', 'when_to_relax'],
    'super_focus_method': ['main', 'in_your_head']
  };
  static const int quizzesCount = 5;
  static const int quizzesRounds = 2;
  static const int timeBetweenQuizzesRounds = 14;
  static const bool showQuizTimer = false;
  static const bool notificationsEnabled = true;
  static const String notificationsTime = '21:00';
}