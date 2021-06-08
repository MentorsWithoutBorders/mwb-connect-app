class NotificationsSettings {
  bool enabled;
  String time;

  NotificationsSettings({this.enabled, this.time});

  NotificationsSettings.fromJson(Map<String, dynamic> snapshot) :
    enabled = snapshot['enabled'] ?? true,
    time = snapshot['time'];

  Map<String, Object> toJson() {
    return {
      'enabled': enabled,
      'time': time
    };
  }
}