import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class InputBox extends StatefulWidget {
  InputBox({@required this.autofocus, @required this.label, this.hint, this.text, this.inputChangedCallback});

  final bool autofocus;
  final String label;
  final String hint;
  final String text;
  final Function(String) inputChangedCallback;  

  @override
  State<StatefulWidget> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  Widget _showLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 3.0, bottom: 8.0),
      child: Text(
        widget.label,
        style: TextStyle(color: AppColors.DOVE_GRAY),
      )
    );
  }

  Widget _showInput() {
    return TextFormField(
      initialValue: widget.text,
      autofocus: widget.autofocus,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        hintText: widget.hint,
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
        widget.inputChangedCallback(value);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        _showLabel(),
        _showInput()
      ],
    );
  }
}
