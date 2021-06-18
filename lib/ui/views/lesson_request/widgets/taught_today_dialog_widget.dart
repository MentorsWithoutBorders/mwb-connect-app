import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/skill_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class TaughtTodayDialog extends StatefulWidget {
  const TaughtTodayDialog({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _TaughtTodayDialogState();
}

class _TaughtTodayDialogState extends State<TaughtTodayDialog> {
  LessonRequestViewModel _lessonRequestProvider;  
  final ScrollController _scrollController = ScrollController();  
  List<bool> _selectedSkills = [];
  bool _isStudentAbsent = false;
  bool _areSkillsRetrieved = false;
  bool _isSubmitting = false;

  Widget _showTaughtTodayDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showSkills(),
          _showDivider(),
          _showStudentPresence(),
          _showSubmitButton()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Text(
          'lesson_request.taught_today'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showText() {
    String student = _lessonRequestProvider.previousLesson.student.name;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        'lesson_request.taught_today_text'.tr(args: [student]),
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.DOVE_GRAY,
          height: 1.2
        )
      ),
    );
  }

  Widget _showSkills() {
    List<Skill> skills = _lessonRequestProvider.skills != null ? _lessonRequestProvider.skills : [];
    _initSkillCheckBoxes(skills);
    List<Widget> skillWidgets = [];
    for (int i = 0; i < skills.length; i++) {
      Widget skillWidget = Row(
        children: <Widget>[
          SizedBox(
            width: 40.0,
            height: 35.0,                      
            child: Checkbox(
              activeColor: AppColors.TANGO,
              value: _selectedSkills[i],
              onChanged: (value) {
                _setSelectedSkills(i);
              },
            ),
          ),
          InkWell(
            child: Text(
              skills[i].name,
              style: TextStyle(
                fontSize: 12.0,
                color: _selectedSkills[i] ? Colors.black : AppColors.DOVE_GRAY
              )
            ),
            onTap: () {
              setState(() {
                _setSelectedSkills(i);
              });
            }
          )
        ]
      );
      skillWidgets.add(skillWidget);
    }
    double height = 250.0;
    if (skillWidgets.length < 7) {
      height = skillWidgets.length * 40.0;
    }
    double heightScrollThumb = 250.0 / (skillWidgets.length / 6);

    if (_areSkillsRetrieved) {
      return Container(
        height: height,
        padding: const EdgeInsets.only(left: 50.0, bottom: 10.0),
        child: DraggableScrollbar(
          controller: _scrollController,
          child: ListView(
            controller: _scrollController,
            children: skillWidgets
          ),
          heightScrollThumb: heightScrollThumb,
          backgroundColor: AppColors.SILVER,
          scrollThumbBuilder: (
            Color backgroundColor,
            Animation<double> thumbAnimation,
            Animation<double> labelAnimation,
            double height, {
            Text labelText,
            BoxConstraints labelConstraints
          }) {
            return FadeTransition(
              opacity: thumbAnimation,
              child: Container(
                height: height,
                width: 5.0,
                color: backgroundColor,
              ),
            );
          }        
        )
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 30.0, bottom: 50.0),
        child: Loader(color: AppColors.DOVE_GRAY)
      );
    }
  }

  void _initSkillCheckBoxes(List<Skill> skills) {
    for (int i = 0; i < skills.length; i++) {
      _selectedSkills.add(false);
    }
  }

  Widget _showDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(bottom: 10.0),
      color: AppColors.BOTTICELLI
    );
  }
  
  Widget _showStudentPresence() {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, bottom: 20.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 35.0,
            height: 35.0,                      
            child: Checkbox(
              activeColor: AppColors.TANGO,
              value: _isStudentAbsent,
              onChanged: (value) {
                _setIsStudentPresent();
              },
            ),
          ),
          InkWell(
            child: Text(
              'lesson_request.student_not_present'.tr(),
              style: TextStyle(
                fontSize: 12.0,
                color: AppColors.DOVE_GRAY
              )
            ),
            onTap: () {
              _setIsStudentPresent();
            }
          )
        ]
      ),
    ); 
  }

  void _setSelectedSkills(int index) {
    setState(() {
      _selectedSkills[index] = !_selectedSkills[index];
    });
  }

  void _setIsStudentPresent() {
    setState(() {
      _isStudentAbsent = !_isStudentAbsent;
    });    
  }
  
  Widget _showSubmitButton() {
   return Center(
      child: Container(
        height: 30.0,
        margin: const EdgeInsets.only(bottom: 5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 1.0,
            primary: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(50.0, 3.0, 50.0, 3.0),
          ), 
          child: !_isSubmitting ? Text(
            'common.submit'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 50.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _submitTaughtToday();
            Navigator.pop(context);
          }
        ),
      ),
    );
  }

  Future<void> _submitTaughtToday() async {
    _setIsSubmitting(true);
    await _lessonRequestProvider.addStudentSkills(_selectedSkills);
    await _lessonRequestProvider.setStudentPresence(!_isStudentAbsent);
  }

  void _setIsSubmitting(bool isSubmitting) {
    setState(() {
      _isSubmitting = isSubmitting;
    });  
  }    
  
  Future<void> _getSkills() async {
    if (!_areSkillsRetrieved) {
      await _lessonRequestProvider.getSkills();
      _areSkillsRetrieved = true;
    }
  }  
  
  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

   return FutureBuilder<void>(
      future: _getSkills(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return _showTaughtTodayDialog();
      }
   );
  }
}