import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class InputBox extends StatelessWidget {
  final bool autofocus;
  final String hint;
  final String text;
  final Function(String) inputChangedCallback;
  final TextEditingController inputController = TextEditingController();

  InputBox({
    Key key,
    @required this.autofocus,
    this.hint,
    this.text,
    this.inputChangedCallback
  }) : super(key: key);  

  Widget _showInput() {
    inputController.value = TextEditingValue(
      text: text,
      selection: TextSelection(
        baseOffset: text.length,
        extentOffset: text.length
      )
    );
    return TextFormField(
      key: key,
      controller: inputController,
      autofocus: autofocus,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
        fontSize: 14.0,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.SILVER
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(
            color: AppColors.SILVER,
            width: 1.0,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
          borderSide: BorderSide(
            color: AppColors.EMERALD,
            width: 1.0,
          ),
        )
      ),
      onChanged: (String value) {
        inputChangedCallback(value);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showInput();
  }
}
