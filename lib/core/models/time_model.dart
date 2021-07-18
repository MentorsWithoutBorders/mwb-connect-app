class Time {
  String from;
  String to;

  Time({this.from, this.to});

  Time.fromJson(Map<String, dynamic> json) {
    from = json['from'] ?? '';
    to = json['to'] ?? '';
  }

  Map<String, Object> toJson() {
    return {
      'from': from,
      'to': to
    };
  }  
}