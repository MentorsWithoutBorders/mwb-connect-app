import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/utils/string_extension.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course_view_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/cancel_course_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/bullet_point_widget.dart';

class Course extends StatefulWidget {
  const Course({Key? key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _CourseState();
}

class _CourseState extends State<Course> {
  MentorCourseViewModel? _mentorCourseProvider;
  String _url = '';

  Widget _showCourseCard() {
    if (_mentorCourseProvider?.isCourse == false) {
      return SizedBox.shrink();
    }
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
              _showText(),
              _showStudents(),
              _showLink(),
              _showCancelButton()
            ]
          )
        ),
      ),
    );
  }

  Widget _showText() {
    if (_mentorCourseProvider?.isCourse == false) {
      return SizedBox.shrink();
    }
    DateFormat dayOfWeekFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    DateFormat dateFormat = DateFormat(AppConstants.dateFormatLesson, 'en');
    DateFormat timeFormat = DateFormat(AppConstants.timeFormatLesson, 'en');    
    CourseModel? course = _mentorCourseProvider?.course;
    CourseMentor mentor = _mentorCourseProvider?.getMentor() as CourseMentor;
    CourseMentor partnerMentor = _mentorCourseProvider?.getPartnerMentor() as CourseMentor;
    String mentorIdentifier = 'common.you'.tr().capitalize();
    if (partnerMentor.id != null) {
      mentorIdentifier += ' ' + 'common.and'.tr() + ' ';
      mentorIdentifier += partnerMentor.name as String;
      mentorIdentifier += ' ';
    }
    String courseDuration = course?.type?.duration.toString() as String;
    Subfield mentorSubfield = _mentorCourseProvider?.getMentorSubfield(mentor) as Subfield;
    Subfield partnerMentorSubfield = _mentorCourseProvider?.getMentorSubfield(partnerMentor) as Subfield;
    String subfieldName = mentorSubfield.name!;
    if (partnerMentorSubfield.id != null && mentorSubfield.id != partnerMentorSubfield.id) {
      subfieldName = mentorSubfield.name! + ' ' + 'common.and'.tr() + ' ' + partnerMentorSubfield.name!;
    }
    String courseDayOfWeek = dayOfWeekFormat.format(course?.startDateTime as DateTime);
    String courseEndDate = dateFormat.format(_mentorCourseProvider?.getCourseEndDate() as DateTime);
    String nextLessonDate = dateFormat.format(_mentorCourseProvider?.getNextLessonDate() as DateTime);
    String nextLessonTime = timeFormat.format(course?.startDateTime as DateTime);
    DateTime now = DateTime.now();
    String timeZone = now.timeZoneName;
    String studentPlural = plural('student', course?.students?.length as int);        
    String at = 'common.at'.tr();
    String until = 'common.until'.tr();
    String text = 'mentor_course.course_text'.tr(args: [mentorIdentifier, courseDuration, subfieldName, courseDayOfWeek, courseEndDate, nextLessonDate, nextLessonTime, timeZone, studentPlural]);
    String firstPart = text.substring(mentorIdentifier.length, text.indexOf(courseDuration));
    String secondPart = text.substring(text.indexOf(courseDuration) + courseDuration.length, text.indexOf(subfieldName));
    String thirdPart = text.substring(text.indexOf(subfieldName) + subfieldName.length, text.indexOf(courseDayOfWeek));
    String fourthPart = text.substring(text.indexOf(courseEndDate) + courseEndDate.length, text.indexOf(nextLessonDate));
    String fifthPart = text.substring(text.indexOf(timeZone) + timeZone.length);
    _url = mentor.meetingUrl as String;

    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 15.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.DOVE_GRAY,
            height: 1.4
          ),
          children: <TextSpan>[
            TextSpan(
              text: mentorIdentifier,
              style: const TextStyle(
                color: AppColors.TANGO
              ) 
            ),
            TextSpan(
              text: firstPart
            ),
            TextSpan(
              text: courseDuration,
              style: const TextStyle(
                color: AppColors.TANGO
              ) 
            ),
            TextSpan(
              text: secondPart
            ),
            TextSpan(
              text: subfieldName,
              style: const TextStyle(
                color: AppColors.TANGO
              ) 
            ),
            TextSpan(
              text: thirdPart
            ),
            TextSpan(
              text: courseDayOfWeek,
              style: const TextStyle(
                color: AppColors.TANGO
              ) 
            ), 
            TextSpan(
              text: ' ' + until + ' '
            ),
            TextSpan(
              text: courseEndDate,
              style: const TextStyle(
                color: AppColors.TANGO
              )
            ),
            TextSpan(
              text: fourthPart
            ),
            TextSpan(
              text: nextLessonDate,
              style: const TextStyle(
                color: AppColors.TANGO
              ) 
            ),
            TextSpan(
              text: ' ' + at + ' '
            ),
            TextSpan(
              text: nextLessonTime + ' ' + timeZone,
              style: const TextStyle(
                color: AppColors.TANGO
              ) 
            ),
            TextSpan(
              text: fifthPart
            )
          ]
        )
      ),
    );
  }  

  Widget _showStudents() {
    List<User>? students = _mentorCourseProvider?.course?.students;
    return Container(
      margin: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 15.0),
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 5.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.SILVER)
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: students?.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40.0,
                  child: BulletPoint()
                ),
                Expanded(
                  child: RichText(
                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.DOVE_GRAY,
                        height: 1.4
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${students?[index].name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        TextSpan(
                          text: ' - ${students?[index].organization?.name}'
                        )
                      ]
                    )
                  )
                )
              ]
            )
          );
        }
      )
    );
  }

  Widget _showLink() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            'mentor_course.course_link'.tr(),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.DOVE_GRAY
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 10.0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  child: Text(
                    _url,                   
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline
                    )
                  ),
                  onTap: () async => await _launchMeetingUrl()
                )
              ),
              _showEditLink()
            ]
          ),
        )
      ]
    );
  }

  Widget _showEditLink() {
    return InkWell(
      child: Container(
        height: 22.0,
        padding: const EdgeInsets.only(left: 5.0, right: 3.0),
        child: Image.asset(
          'assets/images/edit_icon.png'
        ),
      ),
      onTap: () {
        // showDialog(
        //   context: context,
        //   builder: (_) => AnimatedDialog(
        //     widgetInside: ChangeUrlDialog(url: _url)
        //   )
        // );
      }                 
    );
  }

  Future<void> _launchMeetingUrl() async {
    if (await canLaunchUrl(Uri.parse(_url))) {
      await launchUrl(
        Uri.parse(_url),
        mode: LaunchMode.externalApplication,
      );  
    } else {
      throw 'Could not launch $_url';
    }  
  }

  Widget _showCancelButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 30.0,
              margin: const EdgeInsets.only(bottom: 5.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 1.0,
                  primary: AppColors.MONZA,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
                ), 
                child: Text('common.cancel_course'.tr(), style: const TextStyle(color: Colors.white)),
                onPressed: () {
                  _showCancelCourseDialog();
                }
              )
            )
          ]
        ),
      ),
    );
  }

  void _showCancelCourseDialog() {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: CancelCourseDialog()
      ),
    );    
  }

  @override
  Widget build(BuildContext context) {
    _mentorCourseProvider = Provider.of<MentorCourseViewModel>(context);

    return _showCourseCard();
  }
}