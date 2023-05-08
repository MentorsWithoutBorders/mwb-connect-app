import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course_types/course_type_item_widget.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course_types/edit_course_details_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';

class CourseTypes extends StatefulWidget {
  const CourseTypes({Key? key, @required this.courseTypes, @required this.selectedCourseType, @required this.subfields, @required this.availabilities, @required this.previousMeetingUrl, @required this.onSelect, @required this.onSetCourseDetails, @required this.onFindPartner})
    : super(key: key); 

  final List<CourseType>? courseTypes;
  final CourseType? selectedCourseType;
  final List<Subfield>? subfields;
  final List<Availability>? availabilities;
  final String? previousMeetingUrl;
  final Function(String)? onSelect;
  final Function(String, Availability?, String)? onSetCourseDetails;
  final Function? onFindPartner;

  @override
  State<StatefulWidget> createState() => _CourseTypesState();
}

class _CourseTypesState extends State<CourseTypes> {
  bool _shouldShowError = false;

  Widget _showCourseTypesCard() {
    CourseType? selectedCourseType = widget.selectedCourseType;
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
      child: Card(
        elevation: 3.0,
        margin: const EdgeInsets.only(bottom: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ), 
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              _showTitle(),
              _showSelectTitle(),
              _showCourseTypes(),
              if (_shouldShowError) _showError(),
              if (selectedCourseType?.isWithPartner != null) _showActionButton()
            ]
          )
        ),
      ),
    );
  }

  Widget _showTitle() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      child: Center(
        child: Text(
          'mentor_course.start_course'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.TANGO,
            fontSize: 16.0,
            fontWeight: FontWeight.bold
          )
        ),
      ),
    );
  }  

  Widget _showSelectTitle() {
    String title = 'mentor_course.course_type_select_title'.tr();
    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13.0,
          color: AppColors.DOVE_GRAY
        )
      ),
    );
  }

  Widget _showCourseTypes() {
    final List<CourseType>? courseTypes = widget.courseTypes; 
    final CourseType? selectedCourseType = widget.selectedCourseType;   
    final List<Widget> courseTypeWidgets = [];
    if (courseTypes != null) {
      for (int i = 0; i < courseTypes.length; i++) {
        courseTypeWidgets.add(
          CourseTypeItem(
            courseType: courseTypes[i],
            selectedCourseTypeId: selectedCourseType?.id,
            onSelect: _selectCourseType,
          )
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Wrap(
        children: courseTypeWidgets
      )
    );
  }

  void _selectCourseType(String? courseTypeId) {
    CourseType? selectedCourseType = widget.selectedCourseType;
    if (selectedCourseType?.id != courseTypeId) {
      _setShouldShowError(false);
    }
    widget.onSelect!(courseTypeId!);
  }

  Widget _showError() {
    CourseType selectedCourseType = widget.selectedCourseType ?? CourseType();
    List<Subfield>? subfields = widget.subfields;
    List<Availability>? availabilities = widget.availabilities;
    bool hasSubfields = subfields != null && subfields.length > 0;
    bool hasAvailabilities = availabilities != null && availabilities.length > 0;
    String text = '';
    if (selectedCourseType.isWithPartner == true) {
      String withText = 'common.with'.tr() + ' ' + 'common.a'.tr();
      text = 'mentor_course.schedule_course_error'.tr(args: [withText]) + ' ';
      if (!hasSubfields) {
        text += 'mentor_course.schedule_course_error_subfield'.tr();
        if (!hasAvailabilities) {
          text += ' ' + 'common.and'.tr() + ' ';
        }
      }
      if (!hasAvailabilities) {
        text += 'mentor_course.schedule_course_error_availability'.tr();
      }
      text += ' ' + 'common.to'.tr() + ' ';
    } else {
      String withoutText = 'common.without'.tr() + ' ' + 'common.a'.tr();
      text = 'mentor_course.schedule_course_error'.tr(args: [withoutText]) + ' ';
      text += 'mentor_course.schedule_course_error_subfield'.tr();
      text += ' ' + 'common.to'.tr() + ' ';      
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 15.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13.0,
            color: AppColors.MONZA,
            height: 1.4
          ),
          children: <TextSpan>[
            TextSpan(
              text: text           
            ),
            TextSpan(
              text: 'common.your_profile'.tr(),
              style: const TextStyle(
                decoration: TextDecoration.underline
              ),
              recognizer: TapGestureRecognizer()..onTap = () {
                Navigator.push(context, MaterialPageRoute<ProfileView>(builder: (_) => ProfileView()));
              } 
            ),
            TextSpan(
              text: '.'
            )
          ]
        )
      ),
    );
  }  

  Widget _showActionButton() {
    bool isWithPartner = widget.selectedCourseType?.isWithPartner as bool;
    String buttonText = isWithPartner ? 'mentor_course.find_partner'.tr() : 'mentor_course.set_course_details'.tr();
    return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            backgroundColor: AppColors.JAPANESE_LAUREL,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(color: Colors.white)
          ),
          onPressed: () async {
            _doAction(isWithPartner);
          }
        )
      )
    );
  }

  void _doAction(bool isWithPartner) {
    List<Subfield>? subfields = widget.subfields;
    List<Availability>? availabilities = widget.availabilities;
    bool hasSubfields = subfields != null && subfields.length > 0;
    bool hasAvailabilities = availabilities != null && availabilities.length > 0;    
    _setShouldShowError(false);
    if (isWithPartner) {
      if (!hasSubfields || !hasAvailabilities) {
        _setShouldShowError(true);
      } else {
        _findPartner();
      }      
    } else {
      if (!hasSubfields) {
        _setShouldShowError(true);
      } else {
        _editCourseDetails();
      } 
    }
  }

  void _editCourseDetails() {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: EditCourseDetailsDialog(
          subfields: widget.subfields,
          previousMeetingUrl: widget.previousMeetingUrl,
          onSetCourseDetails: widget.onSetCourseDetails
        ),
        marginBottom: 280.0,
      ),
    );
  }

  void _findPartner() {
    widget.onFindPartner!();
  }

  void _setShouldShowError(bool shouldShowError) {
    setState(() {
      _shouldShowError = shouldShowError;
    });
  }
  
  void _handleVisibilityChanged(VisibilityInfo info) {
    final visiblePercentage = info.visibleFraction * 100;
    if (mounted && visiblePercentage == 0.0) {
      _setShouldShowError(false);
    }
  }  

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('course_types'),
      onVisibilityChanged: (VisibilityInfo info) {
        _handleVisibilityChanged(info);
      },
      child: _showCourseTypesCard()
    );
  }
}