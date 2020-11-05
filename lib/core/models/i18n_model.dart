class I18n {
  String id;
  String locales;

  I18n({this.id, this.locales});

  I18n.fromMap(Map snapshot, String id) :
        id = id ?? '',
        locales = snapshot['locales'] ?? '';

  toJson() {
    return {
      'locales': locales
    };
  }
}