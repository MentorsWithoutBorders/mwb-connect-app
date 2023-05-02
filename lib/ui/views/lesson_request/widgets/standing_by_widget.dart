import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/availability_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/ui/views/lesson_request/widgets/add_lessons_dialog_widget.dart';
import 'package:mwb_connect_app/ui/views/profile/profile_view.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';

class StandingBy extends StatefulWidget {
  const StandingBy({Key? key, this.reload})
    : super(key: key); 

  final Function? reload;

  @override
  State<StatefulWidget> createState() => _StandingByState();
}

class _StandingByState extends State<StandingBy> {
  LessonRequestViewModel? _lessonRequestProvider;
  CommonViewModel? _commonProvider;

  Widget _showStandingByCard() {
    bool? isPreviousLesson = _lessonRequestProvider?.isPreviousLesson;
    List<User> previousLessonStudents = _lessonRequestProvider?.previousLesson?.students as List<User>;
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
              Container(
                padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                child: Wrap(
                  children: [
                    _showText(),
                    if (isPreviousLesson == true && previousLessonStudents.length > 0) _showAddMoreLessons()
                  ]
                )
              )
            ],
          )
        ),
      ),
    );
  }

  Widget _showTitle() {
    List<Subfield>? userSubfields = _commonProvider?.user?.field?.subfields;
    List<Availability>? userAvailabilities = _commonProvider?.user?.availabilities;
    bool hasSubfields = userSubfields != null && userSubfields.length > 0;
    bool hasAvailabilities = userAvailabilities != null && userAvailabilities.length > 0;
    String title = 'lesson_request.standing_by'.tr();
    if (!hasSubfields || !hasAvailabilities) {
      title = 'lesson_request.profile_incomplete'.tr();
    }    
    return Container(
      margin: const EdgeInsets.only(top: 3.0, bottom: 15.0),
      child: Center(
        child: Text(
          title,
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

  Widget _showText() {
    List<Subfield>? userSubfields = _commonProvider?.user?.field?.subfields;
    List<Availability>? userAvailabilities = _commonProvider?.user?.availabilities;
    bool hasSubfields = userSubfields != null && userSubfields.length > 0;
    bool hasAvailabilities = userAvailabilities != null && userAvailabilities.length > 0;
    String text = 'lesson_request.standing_by_text'.tr();
    if (!hasSubfields || !hasAvailabilities) {
      text = 'lesson_request.receive_requests_text'.tr() + ' ';
      if (!hasSubfields) {
        text += 'lesson_request.receive_requests_subfield_text'.tr();
        if (!hasAvailabilities) {
          text += ' ' + 'common.and'.tr() + ' ';
        }
      }
      if (!hasAvailabilities) {
        text += 'lesson_request.receive_requests_availability_text'.tr();
      }
      text += ' ' + 'common.to'.tr() + ' ';
    }
    String firstPart = '';
    String secondPart = '';
    String addAvailabilityText = 'common.add_availability'.tr();
    if (!hasAvailabilities) {
      firstPart = text.substring(0, text.indexOf(addAvailabilityText));
      secondPart = text.substring(text.indexOf(addAvailabilityText) + addAvailabilityText.length);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13.0,
            color: AppColors.DOVE_GRAY,
            height: 1.4
          ),
          children: <TextSpan>[
            if (hasAvailabilities) TextSpan(
              text: text           
            ),
            if (!hasAvailabilities) TextSpan(
              text: firstPart           
            ),
            if (!hasAvailabilities) TextSpan(
              text: addAvailabilityText,
              style: const TextStyle(
                fontWeight: FontWeight.bold
              )
            ),
            if (!hasAvailabilities) TextSpan(
              text: secondPart           
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

  Widget _showAddMoreLessons() {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              'common.or'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.0,
                fontFamily: 'RobotoItalic',
                color: AppColors.TANGO
              )
            )
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              'lesson_request.add_more_lessons_text'.tr(),
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 13.0,
                color: AppColors.DOVE_GRAY,
                height: 1.4
              )
            )
          ),
          Container(
            height: 30.0,
            margin: const EdgeInsets.only(bottom: 5.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 1.0,
                backgroundColor: AppColors.ALLPORTS,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
                ),
                padding: const EdgeInsets.fromLTRB(30.0, 3.0, 30.0, 3.0),
              ), 
              onPressed: () {
                _showAddLessonsDialog();
              },
              child: Text(
                'lesson_request.add_more_lessons'.tr(),
                style: const TextStyle(color: Colors.white)
              )
            )
          )
        ]
      ),
    );
  }

  void _showAddLessonsDialog() {
    showDialog(
      context: context,
      builder: (_) => AnimatedDialog(
        widgetInside: AddLessonsDialog(lesson: _lessonRequestProvider?.previousLesson, reload: widget.reload)
      ),
    );    
  }   

  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);
    _commonProvider = Provider.of<CommonViewModel>(context);

    return _showStandingByCard();
  }
}