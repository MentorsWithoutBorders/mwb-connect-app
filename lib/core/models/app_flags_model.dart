class AppFlags {
  bool isTrainingEnabled = true;
  bool isMentoringEnabled = true;

  AppFlags({required this.isTrainingEnabled, required this.isMentoringEnabled});

  AppFlags.fromJson(Map<String, dynamic> json) {
    isTrainingEnabled = json['isTrainingEnabled'] ?? true;
    isMentoringEnabled = json['isMentoringEnabled'] ?? true;
  }

  Map<String, Object?> toJson() {
    return {
      'isTrainingEnabled': isTrainingEnabled,
      'isMentoringEnabled': isMentoringEnabled
    };
  }
}