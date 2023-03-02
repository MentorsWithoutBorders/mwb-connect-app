import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/utils/colors.dart';

class CourseNotesView extends StatefulWidget {
  const CourseNotesView({Key? key, @required this.courseNotes})
    : super(key: key);

  final String? courseNotes;

  @override
  State<StatefulWidget> createState() => _CourseNotesViewState();
}

class _CourseNotesViewState extends State<CourseNotesView> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();  
  String _courseNotes = '';

  @override
  void initState() {
    super.initState();
    _courseNotes = widget.courseNotes ?? '';
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      Navigator.pop(context);
    }
  }  
  
  Widget _showCourseNotesView() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 60.0, 15.0, 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 10.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: _showCourseNotes(),
            )
          )
        ]
      )
    );
  }
  
  Widget _showCourseNotes() {
    final double screenWidth = MediaQuery.of(context).size.width;
    double heightScrollThumb = 150.0;
    if (MediaQuery.of(context).orientation == Orientation.landscape){
      heightScrollThumb = 80.0;
    }    
    return Container(
      width: screenWidth,
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: DraggableScrollbar(
        controller: _scrollController,
        alwaysVisibleScrollThumb: true,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 0.0),
          controller: _scrollController,
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: SelectableText(
                      _courseNotes,
                      style: const TextStyle(
                        fontSize: 13.0
                      ),
                      toolbarOptions: const ToolbarOptions(copy: true),
                      enableInteractiveSelection: true
                    )
                  )
                )
              ]
            );
          },
        ),
        heightScrollThumb: heightScrollThumb,
        backgroundColor: AppColors.SILVER,
        scrollThumbBuilder: (
          Color backgroundColor,
          Animation<double> thumbAnimation,
          Animation<double> labelAnimation,
          double height, {
          Text? labelText,
          BoxConstraints? labelConstraints
        }) {
          return FadeTransition(
            opacity: thumbAnimation,
            child: Container(
              height: height,
              width: 5.0,
              color: backgroundColor
            )
          );
        }
      )
    );
  }
  
  Widget _showTitle() {
    return Container(
      padding: const EdgeInsets.only(right: 50.0),
      child: Center(
        child: Text(
          'common.course_notes'.tr(),
          textAlign: TextAlign.center
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        BackgroundGradient(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: _showTitle(),
            backgroundColor: Colors.transparent,          
            elevation: 0.0,
            leading: GestureDetector(
              onTap: () async { 
                Navigator.pop(context);
              },
              child: Platform.isIOS ? Icon(
                Icons.arrow_back_ios_new
              ) : Icon(
                Icons.arrow_back
              )
            )
          ),
          extendBodyBehindAppBar: true,
          body: _showCourseNotesView()
        )
      ],
    );
  }
}