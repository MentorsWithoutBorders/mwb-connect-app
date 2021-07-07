class Update {
  int major;
  int minor;
  int release;
  int build;

  Update({this.major, this.minor, this.release, this.build});

  Update.fromJson(Map<String, dynamic> json) :
    major = json['major'],
    minor = json['minor'],
    release = json['release'],
    build = json['build'];

  Map<String, Object> toJson() {
    return {
      'major': major,
      'minor': minor,
      'release': release,
      'build': build
    };
  }
}