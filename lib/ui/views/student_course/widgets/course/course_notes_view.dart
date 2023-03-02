import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/viewmodels/student_course/student_course_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class CourseNotesView extends StatefulWidget {
  const CourseNotesView({Key? key})
    : super(key: key);

  @override
  State<StatefulWidget> createState() => _CourseNotesViewState();
}

class _CourseNotesViewState extends State<CourseNotesView> with WidgetsBindingObserver {
  StudentCourseViewModel? _studentCourseProvider;
  final ScrollController _scrollController = ScrollController();
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
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
    final String courseNotes = _studentCourseProvider?.courseNotes ?? '';
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
                    child: _showNotesText()
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

  Widget _showNotesText() {
    final String courseNotes = _studentCourseProvider?.courseNotes ?? '';
    if (courseNotes.isNotEmpty) {
      return SelectableText(
        courseNotes,
        style: const TextStyle(
          fontSize: 13.0
        ),
        toolbarOptions: const ToolbarOptions(copy: true),
        enableInteractiveSelection: true
      );
    }
    return Text(
      'student_course.no_course_notes'.tr(),
      style: TextStyle(
        fontSize: 13.0,
        color: AppColors.SILVER,
        fontStyle: FontStyle.italic
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

  Future<void> _init() async {
    if (!_isInit && _studentCourseProvider != null) { 
      await _studentCourseProvider?.getCourseNotes();
      _isInit = true; 
    } 
  }

  Widget _showContent() {
    if (_isInit) {
      return _showCourseNotesView();
    } else {
      return const Loader();
    }
  }    

  @override
  Widget build(BuildContext context) {
    _studentCourseProvider = Provider.of<StudentCourseViewModel>(context);

    return FutureBuilder<void>(
      future: _init(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {      
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
              body: _showContent()
            )
          ],
        );
      }
    );
  }
}