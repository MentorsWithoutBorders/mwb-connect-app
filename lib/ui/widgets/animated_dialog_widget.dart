import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';

class AnimatedDialog extends StatefulWidget {
  const AnimatedDialog({Key? key, @required this.widgetInside})
    : super(key: key); 

  final Widget? widgetInside;

  @override
  State<StatefulWidget> createState() => AnimatedDialogState();
}

class AnimatedDialogState extends State<AnimatedDialog> with SingleTickerProviderStateMixin {
  CommonViewModel? _commonProvider;
  final GlobalKey<FormState> _containerKey = GlobalKey<FormState>();
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;
  double _containerHeight = 0;
  double _marginBottom = 0;

  @override
  void initState() {
    super.initState();
    _setController();
    _initMarginBottom();
    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(_) {
    _getContainerHeight();
  }
  
  void _getContainerHeight() {
    RenderBox box = _containerKey.currentContext?.findRenderObject() as RenderBox;
    setState(() {
      _containerHeight = box.size.height;
    });
  }  

  void _initMarginBottom() {
    KeyboardVisibilityController keyboardVisibilityController = KeyboardVisibilityController();   
    keyboardVisibilityController.onChange.listen((bool visible) {
      if (visible && mounted) {
        double marginBottom = 120.0;
        final double screenHeight = MediaQuery.of(context).size.height;
        // if (_containerHeight / 2 + 220 > screenHeight / 2) {
        //   marginBottom += (_containerHeight / 2 + 220 - screenHeight / 2) + 120;
        // }
        _setMarginBottom(marginBottom);
      } else {
        _setMarginBottom(0);
      }
    });    
  }

  void _setMarginBottom(double marginBottom) {
    if (mounted) {
      setState(() {
        _marginBottom = marginBottom;
      });
    }
  }

  void _setController() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation = CurvedAnimation(parent: _controller as AnimationController, curve: Curves.easeInQuad);
    _controller?.addListener(() {
      setState(() {});
    });
    _controller?.forward();    
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  
  Widget _showDialog() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation!,
          child: Container(
            key: _containerKey,
            margin: EdgeInsets.only(bottom: _marginBottom),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)
              )
            ),
            child: widget.widgetInside,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _commonProvider = Provider.of<CommonViewModel>(context);
    
    return _showDialog();
  }
}