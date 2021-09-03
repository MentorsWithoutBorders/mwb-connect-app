import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class DeleteStepDialog extends StatefulWidget {
  const DeleteStepDialog({Key? key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _DeleteStepDialogState();
}

class _DeleteStepDialogState extends State<DeleteStepDialog> with TickerProviderStateMixin {
  StepsViewModel? _stepsProvider;
  List<String>? subSteps = [];
  bool _isDeletingStep = false;
  
  Widget _showDeleteStepDialog(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showContent(),
          _showButtons()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Center(
      child: Text(
        subSteps != null && subSteps!.isNotEmpty ? 
          'step_dialog.delete_step_sub_steps_message'.tr() : 
          'step_dialog.delete_step_message'.tr(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold
        )
      )
    );
  }

  Widget _showContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 0.0),
      child: Text(
        _stepsProvider?.selectedStep?.text as String,
        style: const TextStyle(
          fontSize: 14,
        )
      )
    );
  }

  Widget _showButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          InkWell(
            child: Container(
              padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
              child: Text('common.cancel'.tr(), style: const TextStyle(color: Colors.grey))
            ),
            onTap: () {
              Navigator.pop(context);
            }
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: AppColors.MONZA,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              padding: const EdgeInsets.fromLTRB(35.0, 12.0, 35.0, 12.0)
            ), 
            onPressed: () async {
              if (!_isDeletingStep) {
                await _deleteStep(subSteps);
              }
            },
            child: !_isDeletingStep ? Text(
              'step_dialog.delete_step'.tr(), 
              style: const TextStyle(color: Colors.white)
            ) : SizedBox(
              width: 75.0,
              height: 16.0,
              child: ButtonLoader(),
            )
          )
        ]
      )
    );
  }

  Future<void> _deleteStep(List<String>? subSteps) async {
    setState(() {
      _isDeletingStep = true;
    });     
    await _stepsProvider?.deleteStep(_stepsProvider?.selectedStep?.id as String);
    Navigator.pop(context);    
  } 

  @override
  Widget build(BuildContext context) {
    _stepsProvider = Provider.of<StepsViewModel>(context);
    subSteps = _stepsProvider?.getSubSteps(_stepsProvider?.selectedStep?.id);

    return _showDeleteStepDialog(context);
  }
}