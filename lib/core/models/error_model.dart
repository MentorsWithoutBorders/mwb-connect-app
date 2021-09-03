class ErrorModel {
  String? name;
  String? message; 

  ErrorModel({this.name, this.message});

  ErrorModel.fromJson(Map<String, dynamic> json) :
    name = json['name'] ?? '',
    message = json['message'] ?? '';

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'message': message
    };
  }
}