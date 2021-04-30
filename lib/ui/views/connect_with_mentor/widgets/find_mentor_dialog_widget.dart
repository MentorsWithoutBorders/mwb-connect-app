import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/conditions_list_widget.dart';
import 'package:mwb_connect_app/ui/views/goals/goals_view.dart';

class FindMentorDialog extends StatefulWidget {
  const FindMentorDialog({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _FindMentorDialogState();
}

class _FindMentorDialogState extends State<FindMentorDialog> {

  Widget _showFindMentorDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showConditionsText(),
          _showConditionsList(),
          _showGoButton()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Text(
          'connect_with_mentor.find_mentor'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showConditionsText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        'connect_with_mentor.conditions_find_mentor'.tr(),
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.DOVE_GRAY,
          height: 1.2
        )
      ),
    );
  }
  
  Widget _showConditionsList() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ConditionsList(),
    );
  }

  Widget _showGoButton() {
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
          child: Text('common.go'.tr(), style: const TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute<GoalsView>(builder: (_) => GoalsView()));
          }
        ),
      ),
    );
  } 
  
  @override
  Widget build(BuildContext context) {
    return _showFindMentorDialog();
  }
}