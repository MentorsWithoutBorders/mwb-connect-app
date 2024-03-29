import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_schedule_item_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course/mentor_course_view_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/widgets/course/mentor_partnership_schedule_item_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/multicolor_text_widget.dart';

class MentorPartnershipScheduleView extends StatefulWidget {
  const MentorPartnershipScheduleView({Key? key, @required this.mentors, @required this.text, @required this.onUpdateScheduleItem})
    : super(key: key);

  final List<CourseMentor>? mentors;
  final List<ColoredText>? text;
  final Function(String?, String?)? onUpdateScheduleItem;

  @override
  State<StatefulWidget> createState() => _MentorPartnershipScheduleViewState();
}

class _MentorPartnershipScheduleViewState extends State<MentorPartnershipScheduleView> with WidgetsBindingObserver {
  MentorCourseViewModel? _mentorCourseProvider;
  final ScrollController _scrollController = ScrollController();
  bool _isInit = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }  
 
  Widget _showMentorPartnershipScheduleView() {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _showText(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 5.0),
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: _showMentorPartnershipSchedule()
            )
          )
        ]
      )
    );
  }

  Widget _showMentorPartnershipSchedule() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 0.0),
          controller: _scrollController,
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: _showScheduleItems()
            );
          }
        )
      )
    );
  }  
  
  Widget _showScheduleItems() {
    final List<Widget> scheduleWidgets = [];
    final List<MentorPartnershipScheduleItemModel>? partnershipSchedule = _mentorCourseProvider?.mentorPartnershipSchedule;
    if (partnershipSchedule != null) {
      for (int i = 0; i < partnershipSchedule.length; i++) {
        final MentorPartnershipScheduleItemModel scheduleItem = partnershipSchedule[i];
        final List<CourseMentor> mentors = widget.mentors ?? [];
        final Widget scheduleWidget = MentorPartnershipScheduleItem(
          scheduleItem: scheduleItem,
          mentors: mentors,
          onUpdate: _update
        );
        scheduleWidgets.add(scheduleWidget);
      }
    }
    return Wrap(children: scheduleWidgets);
  }  

  Widget _showText() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
      child: MulticolorText(
        coloredTexts: widget.text as List<ColoredText>,
        isSelectable: true,
      )
    );
  }  

  void _update(String? id, String? mentorId) {
    widget.onUpdateScheduleItem!(id, mentorId);
  }
  
  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text(
          'mentor_course.partnership_schedule'.tr(),
          textAlign: TextAlign.center
        )
      )
    );
  }

  Future<void> _init() async {
    if (!_isInit && _mentorCourseProvider != null) { 
      await _mentorCourseProvider?.getMentorPartnershipSchedule();
      _isInit = true; 
    } 
  }

  Widget _showContent() {
    if (_isInit) {
      return _showMentorPartnershipScheduleView();
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: const Loader(),
      );
    }
  }   

  @override
  Widget build(BuildContext context) {
    _mentorCourseProvider = Provider.of<MentorCourseViewModel>(context);

    return FutureBuilder<void>(
      future: _init(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {      
        return Stack(
          children: <Widget>[
            const BackgroundGradient(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: _showTitle(),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                leading: GestureDetector(
                  onTap: () async { 
                    Navigator.pop(context);
                  },
                  child: Platform.isIOS ? Icon(
                    Icons.arrow_back_ios_new
                  ) : Icon(
                    Icons.arrow_back
                  )
                )
              ),
              body: _showContent()
            )
          ]
        );
      }
    );
  }
}