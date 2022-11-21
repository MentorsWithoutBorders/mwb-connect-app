class CourseType {
  String? id;
  int? duration;
  bool? isWithPartner;

  CourseType({this.id, this.duration, this.isWithPartner});

  CourseType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    duration = json['duration'];
    isWithPartner = json['isWithPartner'];
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'duration': duration,
      'isWithPartner': isWithPartner
    };
  }
}