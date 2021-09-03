import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Tag extends StatelessWidget {
  final Color? color;
  final String? id;
  final String? text;
  final Key? textKey;
  final String? deleteImg;
  final Key? deleteKey;
  final Function(String)? tagDeletedCallback;

  Tag({
    Key? key,
    this.color,
    this.id,
    this.text,
    this.textKey,
    this.deleteImg,
    this.deleteKey,
    this.tagDeletedCallback
  }) : super(key: key);  

  Widget _showTag() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(15.0))
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 15.0),
                child: Text(
                  text!,
                  key: textKey,
                  style: TextStyle(
                    fontSize: 12, 
                    color: Colors.white
                  ),
                ),
              ),
              InkWell(
                key: deleteKey,
                child: Container(
                  height: 18.0,
                  padding: const EdgeInsets.only(right: 7.0),
                  child: Image.asset(deleteImg!)
                ),
                onTap: () {
                  tagDeletedCallback!(id!); 
                }
              )
            ],
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showTag();
  }
}
