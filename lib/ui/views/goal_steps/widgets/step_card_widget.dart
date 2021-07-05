import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/ui/views/goal_steps/widgets/step_dialog_widget.dart';
import 'package:mwb_connect_app/ui/widgets/animated_dialog_widget.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class StepCard extends StatefulWidget {
  const StepCard({Key key, @required this.step}): 
    super(key: key);

  final StepModel step;

  @override
  State<StatefulWidget> createState() => _StepCardState();
}

class _StepCardState extends State<StepCard> {
  StepsViewModel _stepsProvider;
  
  Widget _showStepCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(widget.step.level * 20.0 + 16.0, 3.0, 16.0, 10.0),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Colors.white
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: _showBullet(widget.step.level)
                ),
                Expanded(
                  child:Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      widget.step.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0
                      ),
                      overflow: TextOverflow.clip
                    )
                  )
                )
              ] 
            )
          )
        ),
      ),
    );
  }

  Widget _showBullet(int level) {
    const List<bool> isBulletEmpty = [false, true, false];    
    return Container(
      width: 8.0,
      height: 8.0,
      decoration: BoxDecoration(
        border: isBulletEmpty[level] ? Border.all(
          color: AppColors.MONZA,
          width: 1.0,
        ) : null,
        color: !isBulletEmpty[level] ? AppColors.MONZA : null,
        shape: level != 2 ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _stepsProvider = Provider.of<StepsViewModel>(context);

    return GestureDetector(
      onTap: () {
        _stepsProvider.setSelectedStep(widget.step);
        showDialog(
          context: context,
          builder: (_) => AnimatedDialog(
            widgetInside: StepDialog(context: context)
          ),
        ); 
      },
      child: _showStepCard(context)
    );
  }
}

