import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/ui/widgets/button_loader_widget.dart';

class CancelNextLessonDialog extends StatefulWidget {
  const CancelNextLessonDialog({Key? key, @required this.onCancel})
    : super(key: key);

  final Function(String?)? onCancel;
    
  @override
  State<StatefulWidget> createState() => _CancelNextLessonDialogState();
}

class _CancelNextLessonDialogState extends State<CancelNextLessonDialog> {
  String? _reasonText;
  bool _isCanceling = false;

  Widget _showCancelNextLessonDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 15.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showText(),
          _showReasonInput(),
          _showButtons()
        ]
      )
    );
  }

  Widget _showTitle() {
    String title = 'common.cancel_next_lesson'.tr();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showText() {
    String text = 'common.cancel_next_lesson_text'.tr();
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14.0,
          color: AppColors.DOVE_GRAY,
          height: 1.5
        ),
        textAlign: TextAlign.justify
      ),
    );
  }

  Widget _showReasonInput() {
    return Container(
      height: 80.0,
      margin: const EdgeInsets.only(bottom: 15.0),        
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.SILVER)
      ),
      child: TextFormField(
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          fontSize: 13.0
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),          
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: const TextStyle(color: AppColors.SILVER),
          hintText: 'common.cancel_reason_placeholder'.tr(),
        ),
        onChanged: (String? value) => _reasonText = value?.trim(),
      ),
    );
  }
  
  Widget _showButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        InkWell(
          child: Container(
            padding: const EdgeInsets.fromLTRB(30.0, 12.0, 25.0, 12.0),
            child: Text('common.no_abort'.tr(), style: const TextStyle(color: Colors.grey))
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.MONZA,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
          ),
          child: !_isCanceling ? Text(
            'common.yes_cancel'.tr(),
            style: const TextStyle(color: Colors.white)
          ) : SizedBox(
            width: 70.0,
            child: ButtonLoader(),
          ),
          onPressed: () async {
            await _cancelNextLesson();
            Navigator.pop(context);
          },
        )
      ]
    );
  } 

  Future<void> _cancelNextLesson() async {  
    _setIsCanceling(true);
    await widget.onCancel!(_reasonText);
  }
  
  void _setIsCanceling(bool isCanceling) {
    setState(() {
      _isCanceling = isCanceling;
    });  
  }
  
  void _unfocus() {
    FocusScope.of(context).unfocus();
  }  
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _unfocus();
      },
      child: _showCancelNextLessonDialog()
    );
  }
}