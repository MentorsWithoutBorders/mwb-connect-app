import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ButtonLoader extends StatefulWidget {
  const ButtonLoader({Key? key, this.color})
    : super(key: key); 

  final Color? color;

  @override
  State<StatefulWidget> createState() => _ButtonLoaderState();
}

class _ButtonLoaderState extends State<ButtonLoader> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final SpinKitThreeBounce loader = SpinKitThreeBounce(
      color: widget.color != null ? widget.color : Colors.white,
      size: 16.0,
      controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1000)),
    );

    return loader;
  }
}
