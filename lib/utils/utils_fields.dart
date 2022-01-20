import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';

// ignore: avoid_classes_with_only_static_members
class UtilsFields {

  static List<Subfield> getSubfields(int index, Field? selectedField, List<Field>? fields) {
    final List<Subfield>? subfields = fields?[getSelectedFieldIndex(selectedField, fields)].subfields;
    final List<Subfield>? filterSubfields = selectedField?.subfields;
    final List<Subfield> filteredSubfields = [];
    if (subfields != null) {
      for (final Subfield subfield in subfields) {
        if (filterSubfields != null && !containsSubfield(filterSubfields, subfield) || 
            subfield.name == filterSubfields?[index].name) {
          filteredSubfields.add(subfield);
        }
      }
    }
    return filteredSubfields;
  }

  static bool containsSubfield(List<Subfield> subfields, Subfield subfield) {
    bool contains = false;
    for (int i = 0; i < subfields.length; i++) {
      if (subfield.name == subfields[i].name) {
        contains = true;
        break;
      }
    }
    return contains;
  }  

  static int getSelectedFieldIndex(Field? selectedField, List<Field>? fields) {
    return fields!.indexWhere((Field field) => field.id == selectedField?.id);
  }

  static Subfield? getSelectedSubfield(int index, Field? selectedField, List<Field>? fields) {
    Subfield? selectedSubfield;
    final List<Subfield>? subfields = fields?[getSelectedFieldIndex(selectedField, fields)].subfields;
    final List<Subfield>? filterSubfields = selectedField?.subfields;
    if (subfields != null) {
      for (final Subfield subfield in subfields) {
        if (subfield.name == filterSubfields?[index].name) {
          selectedSubfield = subfield;
          break;
        }
      }
    }
    return selectedSubfield;
  }
  
  static String getSkillHintText(int index, Field? selectedField, List<Field>? fields) {
    Subfield? subfield = getSelectedSubfield(index, selectedField, fields);
    String hint = '';
    List<Skill>? subfieldSkills = subfield?.skills;
    if (subfieldSkills != null && subfieldSkills.length > 0) {
      hint = '(' + 'common.eg'.tr() +' ';
      int hintsNumber = 3;
      List<Skill>? subfieldSkills = subfield?.skills;
      if (subfieldSkills != null && subfieldSkills.length < 3) {
        hintsNumber = subfieldSkills.length;
      }
      for (int i = 0; i < hintsNumber; i++) {
        if (subfieldSkills?[i].name != null) {
          String skill = subfieldSkills?[i].name as String;
          hint += skill + ', ';
        }
      }
      hint += 'common.etc'.tr() + ')';
    }
    hint = 'available_mentors.add_skills'.tr(args: [hint]);
    return hint;
  }  
  
  static List<String> getSkillSuggestions(String query, int index, Field? selectedField, List<Field>? fields) {
    List<String> matches = [];
    Subfield? subfield = getSelectedSubfield(index, selectedField, fields);
    List<Skill>? subfieldSkills = subfield?.skills;
    List<Skill>? filterSkills = selectedField?.subfields?[index].skills;
    if (filterSkills != null && subfieldSkills != null) {
      for (final Skill skill in subfieldSkills) {
        bool shouldAdd = true;
        for (final Skill userSkill in filterSkills) {
          if (skill.id == userSkill.id) {
            shouldAdd = false;
            break;
          }
        }
        if (shouldAdd) {
          matches.add(skill.name as String);
        }
      }
      matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    }
    return matches;
  }
  
  static Skill? setSkillToAdd(String skill, int index, Field? selectedField, List<Field>? fields) {
    Skill? skillToAdd;
    List<Skill>? skills = selectedField?.subfields?[index].skills;
    if (skills != null) {
      for (int i = 0; i < skills.length; i++) {
        if (skill.toLowerCase() == skills[i].name?.toLowerCase()) {
          return null;
        }
      }
    }
    Subfield? subfield = getSelectedSubfield(index, selectedField, fields);
    List<Skill>? subfieldSkills = subfield?.skills;
    if (subfieldSkills != null) {
      for (int i = 0; i < subfieldSkills.length; i++) {
        if (skill.toLowerCase() == subfieldSkills[i].name?.toLowerCase()) {
          skillToAdd = subfieldSkills[i];
          break;
        }
      }
    }
    return skillToAdd;
  }
}