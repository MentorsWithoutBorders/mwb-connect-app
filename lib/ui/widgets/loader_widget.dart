import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loader extends StatefulWidget {
  const Loader({Key? key, this.color})
    : super(key: key); 

  final Color? color;

  @override
  State<StatefulWidget> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with TickerProviderStateMixin {
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
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SpinKitFadingCircle loader = SpinKitFadingCircle(
      color: widget.color != null ? widget.color : Colors.white,
      size: 50.0,
      controller: _animationController,
    );

    return Center(
      child: loader,
    );  
  }
}
