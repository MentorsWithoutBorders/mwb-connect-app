import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class InputBox extends StatelessWidget {
  final bool autofocus;
  final String hint;
  final String text;
  final Function(String) inputChangedCallback;

  InputBox({
    @required this.autofocus,
    this.hint,
    this.text,
    this.inputChangedCallback
  });  

  Widget _showInput() {
    return TextFormField(
      initialValue: text,
      autofocus: autofocus,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        fontSize: 14.0,
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.SILVER
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          borderSide: BorderSide(
            color: AppColors.SILVER,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
          borderSide: BorderSide(
            color: AppColors.EMERALD,
            width: 1.0,
          ),
        )
      ),
      onChanged: (value) {
        inputChangedCallback(value);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showInput();
  }
}
