import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/datetime_extension.dart';
import 'package:mwb_connect_app/utils/utils_fields.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';

class AvailableCoursesUtilsService {

  String getFieldName(CourseModel course) {
    String fieldName = '';
    if (course.mentors != null && course.mentors?.length != 0) {
      fieldName = course.mentors![0].field?.name as String;
    }
    return fieldName;
  }

  List<Subfield> getMentorsSubfields(CourseModel course) {
    List<Subfield> subfields = [];
    List<Subfield>? mentorSubfields = course.mentors![0].field?.subfields;
    if (mentorSubfields != null && mentorSubfields.length > 0) {
      subfields.add(mentorSubfields[0]);
      CourseMentor? partnerMentor = course.mentors!.length > 1 ? course.mentors![1] : null;
      List<Subfield>? partnerMentorSubfields = partnerMentor?.field?.subfields;
      if (partnerMentorSubfields != null && partnerMentorSubfields.length > 0) {
        if (partnerMentorSubfields[0].id != mentorSubfields[0].id) {
          subfields.add(partnerMentorSubfields[0]);
        } else {
          subfields[0].skills?.addAll(partnerMentorSubfields[0].skills as List<Skill>);
          // Remove duplicate skills
          subfields[0].skills = subfields[0].skills?.toSet().toList();
        }
      }        
    }
    return subfields;
  }  

  List<Availability> adjustFilterAvailabilities(List<Availability> filterAvailabilities) {
    List<Availability> adjustedFilterAvailabilities = [];
    for (Availability availability in filterAvailabilities) {
      DateFormat timeFormat = DateFormat('ha', 'en');
      DateTime date = Utils.resetTime(DateTime.now());
      List<int> availabilityTimeFrom = Utils.convertTime12to24(availability.time?.from as String);
      DateTime timeFrom = date.copyWith(hour: availabilityTimeFrom[0]);
      if (availabilityTimeFrom[0] > 0) {
        timeFrom = timeFrom.subtract(Duration(hours: 1));
      }
      adjustedFilterAvailabilities.add(Availability(dayOfWeek: availability.dayOfWeek, time: Time(from: timeFormat.format(timeFrom).toLowerCase(), to: availability.time?.to)));
    }
    return adjustedFilterAvailabilities;
  }

  List<Skill> setAllSkills(Field field) {
    List<Skill> allSkills = [];
    List<Subfield> subfields = [];
    if (field.subfields != null) {
      subfields = field.subfields as List<Subfield>;
    }
    for (Subfield subfield in subfields) {
      List<Skill> skills = [];
      if (subfield.skills != null) {
        skills = subfield.skills as List<Skill>;
      }
      for (Skill skill in skills) {
        allSkills.add(skill);
      }
    }
    return allSkills;
  }

  List<Availability> sortFilterAvailabilities(List<Availability> filterAvailabilities) {
    filterAvailabilities.sort((a, b) => Utils.convertTime12to24(a.time?.from as String)[0].compareTo(Utils.convertTime12to24(b.time?.from as String)[0]));
    filterAvailabilities.sort((a, b) => Utils.daysOfWeek.indexOf(a.dayOfWeek as String).compareTo(Utils.daysOfWeek.indexOf(b.dayOfWeek as String)));
    return filterAvailabilities;
  }

  Field getSelectedField(Field filterField, List<Field> fields) {
    return fields.firstWhere((field) => field.id == filterField.id);
  }

  Field setSubfield(Subfield subfield, int index, Field filterField) {
    subfield.skills = [];
    List<Subfield>? filterSubfields = filterField.subfields;
    if (filterSubfields != null && index < filterSubfields.length) {
      filterField.subfields?[index] = subfield;
    } else {
      filterField.subfields?.add(subfield);
    }
    return filterField;
  }

  Field addSubfield(Field filterField, List<Field> fields) {
    final List<Subfield>? subfields = fields[UtilsFields.getSelectedFieldIndex(filterField, fields)].subfields;
    final List<Subfield>? filterSubfields = filterField.subfields;
    if (subfields != null && filterSubfields != null) {
      for (final Subfield subfield in subfields) {
        if (!UtilsFields.containsSubfield(filterSubfields, subfield)) {
          filterField = setSubfield(Subfield(id: subfield.id, name: subfield.name), filterSubfields.length + 1, filterField);
          break;
        }
      }
    }
    return filterField;
  }

  List<Subfield> getSubfieldsAfterDelete(int index, Field filterField) {
    List<Subfield> updatedSubfields = [];
    if (filterField.subfields != null) {
      for (int i = 0; i < filterField.subfields!.length; i++) {
        if (i != index) {
          updatedSubfields.add(filterField.subfields![i]);
        }
      }
    }
    filterField.subfields = updatedSubfields;
    return updatedSubfields;
  }

  Field deleteSkill(String skillId, int index, Field filterField) {
    Skill? skill = filterField.subfields?[index].skills?.firstWhere((skill) => skill.id == skillId);
    filterField.subfields?[index].skills?.remove(skill);
    return filterField;
  }

  double setScrollOffset(double positionDy, double screenHeight, double statusBarHeight) {
    double scrollOffset = 0;
    final double height = screenHeight - statusBarHeight - 340;
    if (positionDy > height) {
      scrollOffset = 100;
    } else if (positionDy < height - 50) {
      scrollOffset = positionDy - height;
    }
    return scrollOffset;
  }
}
