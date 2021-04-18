import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Tag extends StatelessWidget {
  final String text;
  final Color color;
  final String deleteImg;
  final Function(String) tagDeletedCallback;

  Tag({
    Key key,
    this.color,
    this.deleteImg,
    this.text,
    this.tagDeletedCallback
  }) : super(key: key);  

  Widget _showTag() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 30,
          decoration: BoxDecoration(
            color: this.color,
            borderRadius: BorderRadius.all(Radius.circular(15.0))
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 15.0),
                child: Text(
                  this.text,
                  style: TextStyle(
                    fontSize: 12, 
                    color: Colors.white
                  ),
                ),
              ),
              InkWell(
                child: Container(
                  height: 18.0,
                  padding: const EdgeInsets.only(right: 7.0),
                  child: Image.asset(this.deleteImg)
                ),
                onTap: () => this.tagDeletedCallback
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
