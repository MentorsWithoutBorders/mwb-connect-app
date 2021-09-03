import 'dart:math';
import 'package:flutter/material.dart';

class SlideSwipe extends StatefulWidget {
  const SlideSwipe({Key? key, this.width, this.height, this.controller, this.slides})
    : super(key: key);   

  final double? width;
  final double? height;
  final PageController? controller;
  final List<Widget>? slides;
  
  @override
  State<StatefulWidget> createState() => _SlideSwipeState();
}

class _SlideSwipeState extends State<SlideSwipe> {
  int _currentPage = 0;
  bool _initial = false;

  double? _initiate(int index) {
    try {
      _currentPage = widget.controller?.initialPage.round() as int;
    } catch (e) {
      print('exception here => $e');
    }
    double value = 0;
    if (index == _currentPage - 1 && _initial) {
      value = 1.0;
    }
    if (index == _currentPage && _initial) {
      value = 0.0;
    }
    if (index == _currentPage + 1 && _initial) {
      value = 1.0;
      _initial = false;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    _currentPage = 0;
    _initial = true;
    final int count = widget.slides!.length;
    final Widget carouserBuilder = PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: widget.controller,
        itemCount: count,
        itemBuilder: (BuildContext context, int index) => builder(index, widget.controller as PageController));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: widget.height,
          width: widget.width,
          child: carouserBuilder
        ),
      ],
    );
  }

  Widget builder(int index, PageController controller) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        double value = 1.0;
        value = _initial
            ? _initiate(index) ?? controller.page! - index
            : controller.page! - index;
        value = (1 - (value.abs() * .1)).clamp(0.0, 1.0);
        return Opacity(
          opacity: pow(value, 4) as double,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Container(
                  height: widget.height! * value,
                  width: widget.width! * value,
                  child: widget.slides?[index],
                  alignment: Alignment.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
