import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/utils/utils.dart';
import 'package:mwb_connect_app/utils/datetime_extension.dart';
import 'package:mwb_connect_app/utils/utils_availabilities.dart';
import 'package:mwb_connect_app/utils/utils_fields.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/time_model.dart';
import 'package:mwb_connect_app/core/services/available_partner_mentors_service.dart';
import 'package:mwb_connect_app/core/services/mentor_course/mentor_course_api_service.dart';
import 'package:mwb_connect_app/core/services/user_service.dart';

class AvailablePartnerMentorsViewModel extends ChangeNotifier {
  final AvailablePartnerMentorsService _availablePartnerMentorService = locator<AvailablePartnerMentorsService>();
  final MentorCourseApiService _mentorCourseApiService = locator<MentorCourseApiService>();
  final UserService _userService = locator<UserService>();
  List<User> availablePartnerMentors = [];
  List<User> newAvailablePartnerMentors = [];
  List<Field> fields = [];
  List<Availability> filterAvailabilities = [];
  Field filterField = Field();
  User? selectedPartnerMentor;
  String? availabilityOptionId;
  String? subfieldOptionId;
  String? mentorPartnershipRequestButtonId;
  String? selectedCourseStartTime;
  String availabilityMergedMessage = '';
  String errorMessage = '';
  double scrollOffset = 0;
  bool _shouldUnfocus = false;

  Future<void> getAvailablePartnerMentors({int pageNumber = 1}) async {
    _removeOptionAllFilterField();
    User filter = User(
      field: _removeOptionAllFilterField(),
      availabilities: _adjustFilterAvailabilities(filterAvailabilities)
    );
    newAvailablePartnerMentors = await _availablePartnerMentorService.getAvailablePartnerMentors(filter, pageNumber);
    newAvailablePartnerMentors = _adjustMentorsAvailabilities(newAvailablePartnerMentors);
    newAvailablePartnerMentors = _splitMentorsAvailabilities(newAvailablePartnerMentors);
    newAvailablePartnerMentors = _sortMentorsAvailabilities(newAvailablePartnerMentors);
    availablePartnerMentors += newAvailablePartnerMentors;
    setSelectedPartnerMentor(partnerMentor: null);
    setSelectedCourseStartTime(null);    
  }

  Future<void> sendMentorPartnershipRequest() async {
    MentorPartnershipRequestModel mentorPartnershipRequest = MentorPartnershipRequestModel(
      partnerMentor: selectedPartnerMentor as CourseMentor,
      courseDayOfWeek: selectedPartnerMentor?.availabilities![0].dayOfWeek as String,
      courseStartTime: selectedCourseStartTime
    );
    await _mentorCourseApiService.sendMentorPartnershipRequest(mentorPartnershipRequest, null);
  }

  List<Availability> _adjustFilterAvailabilities(List<Availability> filterAvailabilities) {
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

  void mergeAvailabilities() async {
    User student = await _userService.getUserDetails();
    student.availabilities = UtilsAvailabilities.getSortedAvailabilities(student.availabilities);
    student.availabilities = UtilsAvailabilities.getMergedAvailabilities(student.availabilities, '')[0];
    _userService.setUserDetails(student);
  } 

  void setOptionAllFilterField() {
    Field fieldAll = Field(id: 'all', name: 'available_mentors.all_fields'.tr());
    fields.insert(0, fieldAll);
    for (Field field in fields) {
      if (field.subfields != null) {
        Subfield subfieldAll = Subfield(
          id: 'all', 
          name: 'available_mentors.all_subfields'.tr(),
          skills: setAllSkills(field)
        );
        field.subfields?.insert(0, subfieldAll);
      }
    }
    setField(fieldAll);
  }

  Field _removeOptionAllFilterField() {
    Field field = Field.fromJson(filterField.toJson());
    if (field.id == 'all') {
      return Field();
    } else {
      if (field.subfields != null && field.subfields!.length > 0) {
        for (int i = 0; i < field.subfields!.length; i++) {
          if (field.subfields![i].id == 'all' && (field.subfields![i].skills == null || field.subfields![i].skills!.length == 0)) {
            field.subfields!.removeAt(i);
          }
        }
      }
    }
    return field;
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

  bool get isAllFieldsSelected => filterField.id == 'all';

  List<User> _adjustMentorsAvailabilities(List<User> mentors) {
    for (User mentor in mentors) {
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
    return mentors;
  }

  List<User> _splitMentorsAvailabilities(List<User> mentors) {
    for (User mentor in mentors) {
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
    return mentors;
  }

  List<User> _sortMentorsAvailabilities(List<User> mentors) {
    for (User mentor in mentors) {
      mentor.availabilities?.sort((a, b) => Utils.convertTime12to24(a.time?.from as String)[0].compareTo(Utils.convertTime12to24(b.time?.from as String)[0]));
      mentor.availabilities?.sort((a, b) => Utils.daysOfWeek.indexOf(a.dayOfWeek as String).compareTo(Utils.daysOfWeek.indexOf(b.dayOfWeek as String)));
    }
    return mentors;
  }

  void setSelectedPartnerMentor({User? partnerMentor, Subfield? subfield, Availability? availability}) {
    if (partnerMentor != null) {
      if (selectedPartnerMentor == null) {
        selectedPartnerMentor = User(id: partnerMentor.id);
        selectedPartnerMentor?.field = Field(
          id: partnerMentor.field?.id,
          subfields: subfield != null ? [subfield] : [getSelectedSubfield()]
        );
        selectedPartnerMentor?.availabilities = availability != null ? [availability] : [getSelectedAvailability()];
        final String? timeFrom = selectedPartnerMentor?.availabilities![0].time?.from;
        if (timeFrom != null) {
          setSelectedCourseStartTime(timeFrom);
        }
      } else {
        selectedPartnerMentor?.availabilities![0].time?.from = selectedCourseStartTime;
      }
    } else {
      selectedPartnerMentor = null;
    }
    notifyListeners();
  }

  void setSelectedCourseStartTime(String? startTime) {
    selectedCourseStartTime = startTime;
    notifyListeners();
  }  

  void setAvailabilityOptionId(String? id) {
    availabilityOptionId = id;
    if (id != null) {
      String mentorId = id.substring(0, id.indexOf('-a-'));
      if (subfieldOptionId != null && !subfieldOptionId!.contains(mentorId)) {
        subfieldOptionId = null;
      }
    }
    notifyListeners();
  }

  void setSubfieldOptionId(String? id) {
    subfieldOptionId = id;
    if (id != null) {
      String mentorId = id.substring(0, id.indexOf('-s-'));
      if (availabilityOptionId != null && !availabilityOptionId!.contains(mentorId)) {
        availabilityOptionId = null;
      }
    }    
    notifyListeners();
  }

  void setMentorPartnershipRequestButtonId(String? id) {
    mentorPartnershipRequestButtonId = id;   
    notifyListeners();
  }  

  void setDefaultSubfield(User mentor) {
    if (subfieldOptionId != null && mentorPartnershipRequestButtonId != null && !subfieldOptionId!.contains(mentorPartnershipRequestButtonId as String)) {
      setSubfieldOptionId(null);
    }
    if (subfieldOptionId == null) {
      if (mentor.field!.subfields!.length == 1) {
        String mentorId = mentor.id as String;
        setSubfieldOptionId('$mentorId-s-0');
      }
    }
    notifyListeners();
  }

  void setDefaultAvailability(User mentor) {
    if (availabilityOptionId != null && mentorPartnershipRequestButtonId != null && !availabilityOptionId!.contains(mentorPartnershipRequestButtonId as String)) {
      setAvailabilityOptionId(null);
    }
    if (availabilityOptionId == null) {
      if (mentor.availabilities?.length == 1) {
        String mentorId = mentor.id as String;
        setAvailabilityOptionId('$mentorId-a-0');
      }
    }
    notifyListeners();
  }
  
  bool isMentorPartnershipRequestValid(User mentor) {
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
      notifyListeners();
      return false;
    } else if (!isAvailabilityValid) {
      errorMessage = 'available_mentors.please_select_error'.tr() + ' ' + 'available_mentors.availability_error'.tr();
      notifyListeners();
      return false;
    }
    return true;
  }

  void setErrorMessage(String message) {
    errorMessage = message;
  }

  Subfield getSelectedSubfield() {
    if (subfieldOptionId != null) {
      for (final User mentor in availablePartnerMentors) {
        if (mentor.id == selectedPartnerMentor?.id) {
          int index = int.parse(subfieldOptionId!.substring(subfieldOptionId!.indexOf('-s-') + 3));
          return mentor.field?.subfields![index] as Subfield;
        }
      }
    }
    return Subfield();
  }  

  Availability getSelectedAvailability() {
    if (availabilityOptionId != null) {
      for (final User mentor in availablePartnerMentors) {
        if (mentor.id == selectedPartnerMentor?.id) {
          int index = int.parse(availabilityOptionId!.substring(availabilityOptionId!.indexOf('-a-') + 3));
          return mentor.availabilities![index];
        }
      }
    }
    return Availability();
  }

  List<String> buildHoursList() {
    final Availability availability = getSelectedAvailability();
    String timeFrom = availability.time?.from as String;
    String timeTo = availability.time?.to as String;
    int timeFromHours = Utils.convertTime12to24(timeFrom)[0];
    int timeToHours = Utils.convertTime12to24(timeTo)[0];

    List<String> hoursList = [];
    if (timeFromHours < timeToHours) {
      hoursList = _setHours(hoursList, timeFromHours, timeToHours);
    } else {
      hoursList = _setHours(hoursList, timeFromHours, 24);
      hoursList = _setHours(hoursList, 0, timeToHours);
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

  void addAvailability(Availability availability) {
    filterAvailabilities.add(availability);
    _sortFilterAvailabilities();
    List mergedAvailabilities = UtilsAvailabilities.getMergedAvailabilities(filterAvailabilities, availabilityMergedMessage);
    filterAvailabilities = mergedAvailabilities[0];
    availabilityMergedMessage = mergedAvailabilities[1];
    notifyListeners();
  }
  
  void _sortFilterAvailabilities() {
    filterAvailabilities.sort((a, b) => Utils.convertTime12to24(a.time?.from as String)[0].compareTo(Utils.convertTime12to24(b.time?.from as String)[0]));
    filterAvailabilities.sort((a, b) => Utils.daysOfWeek.indexOf(a.dayOfWeek as String).compareTo(Utils.daysOfWeek.indexOf(b.dayOfWeek as String)));
    notifyListeners();
  }
  
  void updateAvailability(int index, Availability newAvailability) {
    filterAvailabilities[index] = newAvailability;
    _sortFilterAvailabilities();
    List mergedAvailabilities = UtilsAvailabilities.getMergedAvailabilities(filterAvailabilities, availabilityMergedMessage);
    filterAvailabilities = mergedAvailabilities[0];
    availabilityMergedMessage = mergedAvailabilities[1];
    notifyListeners();
  }
  
  void deleteAvailability(int index) {
    filterAvailabilities.removeAt(index);
    notifyListeners();
  }
 
  void setField(Field field) async {
    if (filterField.id != field.id) {
      filterField = Field(
        id: field.id, 
        name: field.name, 
        subfields: []
      );
      notifyListeners();
    }
  }

  Field getSelectedField() {
    return fields.firstWhere((field) => field.id == filterField.id);
  }

  void setSubfield(Subfield subfield, int index) {
    subfield.skills = [];
    List<Subfield>? filterSubfields = filterField.subfields;
    if (filterSubfields != null && index < filterSubfields.length) {
      filterField.subfields?[index] = subfield;
    } else {
      filterField.subfields?.add(subfield);
    }
    notifyListeners();
  }

  void addSubfield() {
    final List<Subfield>? subfields = fields[UtilsFields.getSelectedFieldIndex(filterField, fields)].subfields;
    final List<Subfield>? filterSubfields = filterField.subfields;
    if (subfields != null && filterSubfields != null) {
      for (final Subfield subfield in subfields) {
        if (!UtilsFields.containsSubfield(filterSubfields, subfield)) {
          setSubfield(Subfield(id: subfield.id, name: subfield.name), filterSubfields.length + 1);
          break;
        }
      }
    }
    notifyListeners();
  }
  
  void deleteSubfield(int index) async {
    List<Subfield> updatedSubfields = [];
    if (filterField.subfields != null) {
      for (int i = 0; i < filterField.subfields!.length; i++) {
        if (i != index) {
          updatedSubfields.add(filterField.subfields![i]);
        }
      }
    }
    filterField.subfields = [];
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    filterField.subfields = updatedSubfields;
    notifyListeners();
  }

  bool addSkill(String skill, int index) {
    Skill? skillToAdd = UtilsFields.setSkillToAdd(skill, index, filterField, fields);
    if (skillToAdd != null) {
      filterField.subfields?[index].skills?.add(skillToAdd);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void deleteSkill(String skillId, int index) {
    Skill? skill = filterField.subfields?[index].skills?.firstWhere((skill) => skill.id == skillId);
    filterField.subfields?[index].skills?.remove(skill);
    notifyListeners();
  }  

  void resetAvailabilityMergedMessage() {
    availabilityMergedMessage = '';
  }  
  
  void setScrollOffset(double positionDy, double screenHeight, double statusBarHeight) {
    final double height = screenHeight - statusBarHeight - 340;
    if (positionDy > height) {
      scrollOffset = 100;
    } else if (positionDy < height - 50) {
      scrollOffset = positionDy - height;
    }
  }    
  
  bool get shouldUnfocus => _shouldUnfocus;
  set shouldUnfocus(bool unfocus) {
    _shouldUnfocus = unfocus;
    if (shouldUnfocus) {
      notifyListeners();
    }
  }

  void resetValues() {
    availablePartnerMentors = [];
    filterAvailabilities = [];
    filterField = Field();
    selectedPartnerMentor = null;
    selectedCourseStartTime = null;
  }  
}
