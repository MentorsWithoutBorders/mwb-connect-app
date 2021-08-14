import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/step_model.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';
import 'package:mwb_connect_app/core/viewmodels/steps_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class UpdateStepDialog extends StatefulWidget {
  const UpdateStepDialog({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _UpdateStepDialogState();
}

class _UpdateStepDialogState extends State<UpdateStepDialog> with TickerProviderStateMixin {
  CommonViewModel _commonProvider;
  StepsViewModel _stepsProvider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _stepText;
  bool _isUpdatingStep = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(_) {
    _getFormHeight();
  }
  
  void _getFormHeight() {
    RenderBox box = _formKey.currentContext.findRenderObject();
    _commonProvider.setDialogInputHeight(box.size.height);
  }  

  Widget _showUpdateStepDialog(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showInput(),
          _showButtons()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Center(
      child: Text(
        'step_dialog.update_step'.tr(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold
        )
      )
    );
  }

  Widget _showInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Form(
        key: _formKey,
        child: TextFormField(
          autofocus: true,  
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          decoration: InputDecoration(
            hintText: 'step_dialog.update_step_placeholder'.tr(),
            hintStyle: const TextStyle(
              color: AppColors.SILVER
            ),
            enabledBorder: const UnderlineInputBorder(      
              borderSide: BorderSide(color: AppColors.ALLPORTS),   
            ),  
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.ALLPORTS),
            ), 
            errorStyle: const TextStyle(
              color: Colors.orange
            )
          ),
          initialValue: _stepsProvider.selectedStep.text,
          validator: (value) {
            if (value.isEmpty) {
              return 'step_dialog.update_step_error'.tr();
            }
            return null;
          },
          onChanged: (String value) {
            Future<void>.delayed(const Duration(milliseconds: 10), () {        
              if (value.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
                _formKey.currentState.validate();
              }
            });
          },
          onSaved: (String value) => _stepText = value
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
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: AppColors.JAPANESE_LAUREL,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              padding: const EdgeInsets.fromLTRB(35.0, 12.0, 35.0, 12.0)
            ),
            onPressed: () async {
              if (_formKey.currentState.validate() && !_isUpdatingStep) {
                _formKey.currentState.save();
                await _updateStep();
                Navigator.pop(context);
              }                    
            },
            child: !_isUpdatingStep ? Text(
              'step_dialog.update_step'.tr(), 
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
  
  Future<void> _updateStep() async {
    setState(() {
      _isUpdatingStep = true;
    });    
    final StepModel step = _stepsProvider.selectedStep;
    step.text = _stepText;
    await _stepsProvider.updateStep(step, _stepsProvider.selectedStep.id);
  }

  @override
  Widget build(BuildContext context) {
    _commonProvider = Provider.of<CommonViewModel>(context);
    _stepsProvider = Provider.of<StepsViewModel>(context);

    return _showUpdateStepDialog(context);
  }
}