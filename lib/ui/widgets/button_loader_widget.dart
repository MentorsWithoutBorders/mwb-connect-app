import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ButtonLoader extends StatefulWidget {
  const ButtonLoader({Key? key, this.color})
    : super(key: key); 

  final Color? color;

  @override
  State<StatefulWidget> createState() => _ButtonLoaderState();
}

class _ButtonLoaderState extends State<ButtonLoader> with TickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _setAnimationController();
  } 

  void _setAnimationController() { 
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
  }
  
  @override
  dispose() {
    _animationController?.dispose(); // you need this
    super.dispose();
  }  

  @override
  Widget build(BuildContext context) {
    final SpinKitThreeBounce loader = SpinKitThreeBounce(
      color: widget.color != null ? widget.color : Colors.white,
      size: 16.0,
      controller: _animationController,
    );

    return loader;
  }
}
