import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/datetime_extension.dart';
import 'package:mwb_connect_app/utils/utils_fields.dart';
import 'package:mwb_connect_app/core/models/mentor_waiting_request_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';

class MentorsWaitingRequestsUtilsService {

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
      adjustedFilterAvailabilities.add(Availability(
        dayOfWeek: availability.dayOfWeek,
        time: Time(
          from: timeFormat.format(timeFrom).toLowerCase(),
          to: availability.time?.to
        )
      ));
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
  
  List<MentorWaitingRequest> adjustMentorsAvailabilities(List<MentorWaitingRequest> mentorsWaitingRequests) {
    for (MentorWaitingRequest mentorWaitingRequest in mentorsWaitingRequests) {
      CourseMentor mentor = mentorWaitingRequest.mentor as CourseMentor;
      List<Availability> availabilities = [];
      for (Availability availability in mentor.availabilities as List<Availability>) {
        DateFormat timeFormat = DateFormat('ha', 'en');    
        DateTime date = Utils.resetTime(DateTime.now());
        List<int> availabilityTimeFrom = Utils.convertTime12to24(availability.time?.from as String);
        List<int> availabilityTimeTo = Utils.convertTime12to24(availability.time?.to as String);
        DateTime timeFrom = date.copyWith(hour: availabilityTimeFrom[0]);
        DateTime timeTo = date.copyWith(hour: availabilityTimeTo[0]);
        bool hasScheduledLesson = mentor.hasScheduledLesson ?? false;
        if (!hasScheduledLesson && availabilityTimeFrom[1] > 0) {
          timeFrom = timeFrom.add(Duration(hours: 1));
          timeTo = timeTo.add(Duration(hours: 1));
        }
        availabilities.add(Availability(
          dayOfWeek: availability.dayOfWeek,
          time: Time(
            from: timeFormat.format(timeFrom).toLowerCase(),
            to: timeFormat.format(timeTo).toLowerCase()
          )
        ));
      }
      mentor.availabilities = availabilities;
    }
    return mentorsWaitingRequests;
  }
  
  List<MentorWaitingRequest> splitMentorsAvailabilities(List<MentorWaitingRequest> mentorsWaitingRequests) {
    for (MentorWaitingRequest mentorWaitingRequest in mentorsWaitingRequests) {
      CourseMentor mentor = mentorWaitingRequest.mentor as CourseMentor;
      List<Availability> availabilities = [];
      for (Availability availability in mentor.availabilities as List<Availability>) {
        if (Utils.convertTime12to24(availability.time?.from as String)[0] > Utils.convertTime12to24(availability.time?.to as String)[0]) {
          availabilities.add(Availability(
            dayOfWeek: Utils.getNextDayOfWeek(availability.dayOfWeek as String),
            time: Time(
              from: '12am',
              to: availability.time?.to
            )
          ));
          availability.time?.to = '12am';
          availabilities.add(availability);
        } else {
          availabilities.add(availability);
        }
      }
      mentor.availabilities = availabilities;
    }
    return mentorsWaitingRequests;
  }
  
  List<MentorWaitingRequest> sortMentorsAvailabilities(List<MentorWaitingRequest> mentorsWaitingRequests) {
    for (MentorWaitingRequest mentorWaitingRequest in mentorsWaitingRequests) {
      CourseMentor mentor = mentorWaitingRequest.mentor as CourseMentor;
      mentor.availabilities?.sort((a, b) => Utils.convertTime12to24(a.time?.from as String)[0].compareTo(Utils.convertTime12to24(b.time?.from as String)[0]));
      mentor.availabilities?.sort((a, b) => Utils.daysOfWeek.indexOf(a.dayOfWeek as String).compareTo(Utils.daysOfWeek.indexOf(b.dayOfWeek as String)));
    }
    return mentorsWaitingRequests;
  }

  String getErrorMessage(String? mentorId, String? mentorPartnershipRequestButtonId, String? subfieldOptionId, String? availabilityOptionId) {
    if (mentorPartnershipRequestButtonId != mentorId) {
      return '';
    }
    String errorMessage = '';
    bool isSubfieldValid = true;
    bool isAvailabilityValid = true;
    if (subfieldOptionId == null) {
      isSubfieldValid = false;
    }
    if (availabilityOptionId == null) {
      isAvailabilityValid = false;
    }
    if (!isSubfieldValid) {
      errorMessage = 'available_mentors.please_select_error'.tr() + ' ' + 'available_mentors.subfield_error'.tr();
      if (!isAvailabilityValid) {
        errorMessage += ' ' + 'common.and'.tr() + ' '  + 'available_mentors.availability_error'.tr();
      }
    } else if (!isAvailabilityValid) {
      errorMessage = 'available_mentors.please_select_error'.tr() + ' ' + 'available_mentors.availability_error'.tr();
    }
    return errorMessage;
  }
  
  String getSubfieldItemId(String mentorId, int index) {
    return mentorId + '-s-' + index.toString();
  }
  
  String getAvailabilityItemId(String mentorId, int index) {
    return mentorId + '-a-' + index.toString();
  }  
  
  Subfield getSelectedSubfield(String? subfieldOptionId, List<MentorWaitingRequest> mentorsWaitingRequests, CourseMentor? selectedPartnerMentor) {
    if (subfieldOptionId != null) {
      CourseMentor mentor = _getMentorById(selectedPartnerMentor?.id, mentorsWaitingRequests);
      int index = int.parse(subfieldOptionId.substring(subfieldOptionId.indexOf('-s-') + 3));
      return mentor.field?.subfields![index] as Subfield;      
    }
    return Subfield();
  }

  CourseMentor _getMentorById(String? mentorId, List<MentorWaitingRequest> mentorsWaitingRequests) {
    CourseMentor mentor = CourseMentor();
    for (MentorWaitingRequest mentorWaitingRequest in mentorsWaitingRequests) {
      if (mentorWaitingRequest.mentor?.id == mentorId) {
        mentor = mentorWaitingRequest.mentor as CourseMentor;
        break;
      }
    }
    return mentor;
  }  

  Availability getSelectedAvailability(String? availabilityOptionId, List<MentorWaitingRequest> mentorsWaitingRequests, CourseMentor? selectedPartnerMentor) {
    if (availabilityOptionId != null) {
      CourseMentor mentor = _getMentorById(selectedPartnerMentor?.id, mentorsWaitingRequests);
      int index = int.parse(availabilityOptionId.substring(availabilityOptionId.indexOf('-a-') + 3));
      return mentor.availabilities![index];      
    }
    return Availability();
  }

  String? getDefaultSubfield(CourseMentor mentor, String? subfieldOptionId, String? mentorPartnershipRequestButtonId) {
    if (subfieldOptionId != null && mentorPartnershipRequestButtonId != null && !subfieldOptionId.contains(mentorPartnershipRequestButtonId)) {
      return null;
    }
    if (subfieldOptionId == null) {
      if (mentor.field!.subfields!.length == 1) {
        String mentorId = mentor.id as String;
        return '$mentorId-s-0';
      }
    }
    return null;
  }

  String? getDefaultAvailability(CourseMentor mentor, String? availabilityOptionId, String? mentorPartnershipRequestButtonId) {
    if (availabilityOptionId != null && mentorPartnershipRequestButtonId != null && !availabilityOptionId.contains(mentorPartnershipRequestButtonId)) {
      return null;
    }
    if (availabilityOptionId == null) {
      if (mentor.availabilities?.length == 1) {
        String mentorId = mentor.id as String;
        return '$mentorId-a-0';
      }
    }
    return null;
  }
  
  List<String> buildHoursList(String? availabilityOptionId, List<MentorWaitingRequest> mentorsWaitingRequests, CourseMentor? selectedPartnerMentor) {
    List<String> hoursList = [];
    if (selectedPartnerMentor != null) {
      final Availability availability = getSelectedAvailability(availabilityOptionId, mentorsWaitingRequests, selectedPartnerMentor);
      if (availability.time != null) {
        String timeFrom = availability.time?.from as String;
        String timeTo = availability.time?.to as String;
        int timeFromHours = Utils.convertTime12to24(timeFrom)[0];
        int timeToHours = Utils.convertTime12to24(timeTo)[0];

        if (timeFromHours < timeToHours) {
          hoursList = _setHours(hoursList, timeFromHours, timeToHours);
        } else {
          hoursList = _setHours(hoursList, timeFromHours, 24);
          hoursList = _setHours(hoursList, 0, timeToHours);
        }
      }
    }
    return hoursList;
  }
  
  List<String> _setHours(List<String> hoursList, int from, int to) {
    if (from < 12) {
      if (to < 12) {
        hoursList = _addHours(hoursList, from, to - 1, 'am');
      } else {
        hoursList = _addHours(hoursList, from, 11, 'am');
        if (to > 12) {
          hoursList.add('12pm');
          hoursList = _addHours(hoursList, 1, to - 13, 'pm');
        }
      }
    } else {
      if (from == 12) {
        hoursList.add('12pm');
        hoursList = _addHours(hoursList, from - 11, to - 13, 'pm');
      } else {
        hoursList = _addHours(hoursList, from - 12, to - 13, 'pm');
      }
    }
    return hoursList;
  }

  List<String> _addHours(List<String> hoursList, int from, int to, String modifier) {
    for (int i = from; i <= to; i++) {
      if (i == 0) {
        hoursList.add('12am');
      } else {
        hoursList.add(i.toString() + modifier);
      }
    }
    return hoursList;
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
  
  Field deleteSubfield(int index, Field filterField) {
    List<Subfield> updatedSubfields = [];
    if (filterField.subfields != null) {
      for (int i = 0; i < filterField.subfields!.length; i++) {
        if (i != index) {
          updatedSubfields.add(filterField.subfields![i]);
        }
      }
    }
    filterField.subfields = updatedSubfields;
    return filterField;
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