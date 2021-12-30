import 'package:flutter/material.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class InputBox extends StatelessWidget {
  final bool? autofocus;
  final String? hint;
  final String? text;
  final TextCapitalization? textCapitalization;
  final Function(String)? inputChangedCallback;

  InputBox({
    Key? key,
    @required this.autofocus,
    this.hint,
    this.text,
    this.textCapitalization,
    this.inputChangedCallback
  }) : super(key: key);  

  Widget _showInput() {
    return TextFormField(
      key: key,
      autofocus: autofocus!,
      textCapitalization: textCapitalization!,
      style: const TextStyle(
        fontSize: 14.0,
      ),
      initialValue: text,
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
        inputChangedCallback!(value);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showInput();
  }
}
