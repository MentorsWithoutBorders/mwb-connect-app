import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/views/goals/goals_view.dart';

class LearnedTodayDialog extends StatefulWidget {
  const LearnedTodayDialog({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _LearnedTodayDialogState();
}

class _LearnedTodayDialogState extends State<LearnedTodayDialog> {
  final ScrollController _scrollController = ScrollController();  
  List<bool> _skillCheckBoxes = [];
  bool _mentorCheckBox = false;

  @override
  void initState() {
    super.initState();
    _skillCheckBoxes = [false, false, false, false, false, false, false, false];
  }

  Widget _showLearnedTodayDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showSkillsList(),
          _showDivider(),
          _showMentorPresence(),
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
          'connect_with_mentor.learned_today'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        'connect_with_mentor.learned_today_text'.tr(),
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
  
  Widget _showMentorPresence() {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, bottom: 20.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 35.0,
            height: 35.0,                      
            child: Checkbox(
              activeColor: AppColors.TANGO,
              value: _mentorCheckBox,
              onChanged: (value) {
                _setMentorCheckBox();
              },
            ),
          ),
          InkWell(
            child: Text(
              'connect_with_mentor.mentor_not_present'.tr(),
              style: TextStyle(
                fontSize: 12.0,
                color: AppColors.DOVE_GRAY
              )
            ),
            onTap: () {
              _setMentorCheckBox();
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

  void _setMentorCheckBox() {
    setState(() {
      _mentorCheckBox = !_mentorCheckBox;
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
    return _showLearnedTodayDialog();
  }
}