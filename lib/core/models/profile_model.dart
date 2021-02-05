import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';

class Profile {
  User user;
  List<Field> fields;
  List<Subfield> subfields;

  Profile({this.user, this.fields, this.subfields});
}
