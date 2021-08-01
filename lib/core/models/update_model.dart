class Update {
  int major;
  int minor;
  int revision;
  int build;

  Update({this.major, this.minor, this.revision, this.build});

  Update.fromJson(Map<String, dynamic> json) :
    major = json['major'],
    minor = json['minor'],
    revision = json['revision'],
    build = json['build'];

  Map<String, Object> toJson() {
    return {
      'major': major,
      'minor': minor,
      'revision': revision,
      'build': build
    };
  }
}