class Update {
  int major;
  int minor;
  int release;
  int build;

  Update({this.major, this.minor, this.release, this.build});

  Update.fromJson(Map<String, dynamic> snapshot) :
    major = snapshot['major'],
    minor = snapshot['minor'],
    release = snapshot['release'],
    build = snapshot['build'];

  Map<String, Object> toJson() {
    return {
      'major': major,
      'minor': minor,
      'release': release,
      'build': build
    };
  }
}