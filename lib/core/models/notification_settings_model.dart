class NotificationSettings {
  String id;
  bool enabled;
  String time;

  NotificationSettings({this.id, this.enabled, this.time});

  NotificationSettings.fromMap(Map snapshot, String id) :
    id = id,
    enabled = snapshot['enabled'] ?? true,
    time = snapshot['time'];

  Map<String, Object> toJson() {
    return {
      'enabled': enabled,
      'time': time
    };
  }
}