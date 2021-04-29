import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/keys.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/connect_with_mentor_view_model.dart';
import 'package:mwb_connect_app/ui/views/connect_with_mentor/widgets/conditions_list.dart';

class SolveQuizAddStep extends StatefulWidget {
  const SolveQuizAddStep({Key key})
    : super(key: key); 

  @override
  State<StatefulWidget> createState() => _SolveQuizAddStepState();
}

class _SolveQuizAddStepState extends State<SolveQuizAddStep> {
  ConnectWithMentorViewModel _connectWithMentorProvider;

  Widget _showSolveQuizAddStepCard() {
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
                padding: const EdgeInsets.only(left: 3.0),
                child: Wrap(
                  children: [
                    _showTopText(),
                    ConditionsList(),
                    _showNextDeadline(),
                    _showGoButton()
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
    return Container(
      margin: const EdgeInsets.only(left: 3.0, bottom: 15.0),
      child: Text(
        'Solve quiz and add step',
        style: const TextStyle(
          color: AppColors.TANGO,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }   

  Widget _showTopText() {
    String text = 'connect_with_mentor.conditions_certificate'.tr(args: ['Jun 15, 2021']);
    String and = 'common.and'.tr();
    String firstPart = text.substring(0, text.indexOf(and));
    String secondPart = text.substring(text.indexOf(and) + and.length, text.length);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.DOVE_GRAY,
            height: 1.2
          ),
          children: <TextSpan>[
            TextSpan(
              text: firstPart,             
            ),
            TextSpan(
              text: and,
              style: const TextStyle(
                fontStyle: FontStyle.italic
              )
            ),
            TextSpan(
              text: secondPart
            ),
          ],
        )
      ),
    );
  }
  
  Widget _showNextDeadline() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.DOVE_GRAY,
            height: 1.2
          ),
          children: <TextSpan>[
            TextSpan(
              text: 'connect_with_mentor.next_deadline'.tr(),             
            ),
            TextSpan(
              text: 'May 20, 2021',
              style: const TextStyle(
                color: AppColors.TANGO
              )
            ),
          ],
        )
      ),
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
            print('Go');
          }
        ),
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    _connectWithMentorProvider = Provider.of<ConnectWithMentorViewModel>(context);

    return _showSolveQuizAddStepCard();
  }
}