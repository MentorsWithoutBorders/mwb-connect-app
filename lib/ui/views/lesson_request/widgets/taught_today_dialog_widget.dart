import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class TaughtTodayDialog extends StatefulWidget {
  const TaughtTodayDialog({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _TaughtTodayDialogState();
}

class _TaughtTodayDialogState extends State<TaughtTodayDialog> {
  final ScrollController _scrollController = ScrollController();  
  List<bool> _skillCheckBoxes = [];
  bool _studentCheckBox = false;

  @override
  void initState() {
    super.initState();
    _skillCheckBoxes = [false, false, false, false, false, false, false, false];
  }

  Widget _showTaughtTodayDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showSkillsList(),
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
    String student = 'Noel';
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

  Widget _showSkillsList() {
    List<String> skills = ['HTML', 'CSS', 'JavaScript', 'Python', 'Django', 'Java', 'Spring','C#'];
    List<Widget> skillWidgets = [];
    for (int i = 0; i < skills.length; i++) {
      Widget skillWidget = Row(
        children: <Widget>[
          SizedBox(
            width: 40.0,
            height: 35.0,                      
            child: Checkbox(
              activeColor: AppColors.TANGO,
              value: _skillCheckBoxes[i],
              onChanged: (value) {
                _setSkillCheckBox(i);
              },
            ),
          ),
          InkWell(
            child: Text(
              skills[i],
              style: TextStyle(
                fontSize: 12.0,
                color: _skillCheckBoxes[i] ? Colors.black : AppColors.DOVE_GRAY
              )
            ),
            onTap: () {
              setState(() {
                _setSkillCheckBox(i);
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
              value: _studentCheckBox,
              onChanged: (value) {
                _setStudentCheckBox();
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
              _setStudentCheckBox();
            }
          )
        ]
      ),
    ); 
  }

  void _setSkillCheckBox(int index) {
    setState(() {
      _skillCheckBoxes[index] = !_skillCheckBoxes[index];
    });
  }

  void _setStudentCheckBox() {
    setState(() {
      _studentCheckBox = !_studentCheckBox;
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
          child: Text('common.submit'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.pop(context);
          }
        ),
      ),
    );
  } 
  
  @override
  Widget build(BuildContext context) {
    return _showTaughtTodayDialog();
  }
}