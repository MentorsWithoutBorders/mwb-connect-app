class Update {
  String id;
  int major;
  int minor;
  int release;
  int build;

  Update({this.id, this.major, this.minor, this.release, this.build});

  Update.fromMap(Map snapshot, String id) :
    id = id,
    major = snapshot['major'],
    minor = snapshot['minor'],
    release = snapshot['release'],
    build = snapshot['build'];

  toJson() {
    return {
      'major': major,
      'minor': minor,
      'release': release,
      'build': build
    };
  }
}