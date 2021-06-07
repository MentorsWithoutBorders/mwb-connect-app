class NotificationSettings {
  bool enabled;
  String time;

  NotificationSettings({this.enabled, this.time});

  NotificationSettings.fromJson(Map<String, dynamic> snapshot) :
    enabled = snapshot['enabled'] ?? true,
    time = snapshot['time'];

  Map<String, Object> toJson() {
    return {
      'enabled': enabled,
      'time': time
    };
  }
}