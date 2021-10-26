class Ids {
  List<String> listIds = [];

  Ids({required this.listIds});

  Ids.fromJson(Map<String, dynamic> json) :
    listIds = json['listIds']?.cast<String>() ?? [];

  Map<String, Object?> toJson() {
    return {
      'listIds': listIds
    };
  }
}