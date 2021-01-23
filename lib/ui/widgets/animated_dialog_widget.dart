import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mwb_connect_app/core/viewmodels/common_view_model.dart';

class AnimatedDialog extends StatefulWidget {
  AnimatedDialog({@required this.widgetInside, this.hasInput});

  final Widget widgetInside;
  final bool hasInput;

  @override
  State<StatefulWidget> createState() => AnimatedDialogState();
}

class AnimatedDialogState extends State<AnimatedDialog>
    with SingleTickerProviderStateMixin {
  CommonViewModel _commonProvider;      
  AnimationController _controller;
  Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setController();
  }

  void _setController() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInQuad);
    _controller.addListener(() {
      setState(() {});
    });
    _controller.forward();    
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
  
  Widget _showDialog() {
    double marginBottom = widget.hasInput ? _commonProvider.dialogInputHeight + 45 : 50.0;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: EdgeInsets.only(bottom: marginBottom),
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