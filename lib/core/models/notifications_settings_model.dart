class NotificationsSettings {
  bool enabled;
  String time;

  NotificationsSettings({this.enabled, this.time});

  NotificationsSettings.fromJson(Map<String, dynamic> json) :
    enabled = json['enabled'] ?? true,
    time = json['time'];

  Map<String, Object> toJson() {
    return {
      'enabled': enabled,
      'time': time
    };
  }
}