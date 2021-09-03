class TimeZoneModel {
  String? name;
  String? abbreviation;
  String? offset;

  TimeZoneModel({this.name, this.abbreviation, this.offset});

  TimeZoneModel.fromJson(Map<String, dynamic> json) :
    name = json['name'],
    abbreviation = json['abbreviation'],
    offset = json['offset'];

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'abbreviation': abbreviation,
      'offset': offset
    };
  }  
}