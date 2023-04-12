import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/models/course_result_model.dart';
import 'package:mwb_connect_app/core/models/course_student_model.dart';
import 'package:mwb_connect_app/core/models/next_lesson_student_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/colored_text_model.dart';
import 'package:mwb_connect_app/core/models/error_model.dart';
import 'package:mwb_connect_app/core/viewmodels/student_course/available_courses_view_model.dart';
import 'package:mwb_connect_app/ui/views/student_course/available_courses_filters/available_courses_filters_view.dart';
import 'package:mwb_connect_app/ui/views/student_course/available_courses/widgets/available_course_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class AvailableCoursesView extends StatefulWidget {
  const AvailableCoursesView({Key? key})
    : super(key: key);

  @override
  State<StatefulWidget> createState() => _AvailableCoursesViewState();
}

class _AvailableCoursesViewState extends State<AvailableCoursesView> {
  AvailableCoursesViewModel? _availableCoursesProvider;
  final PagingController<int, CourseModel> _pagingController =
        PagingController(firstPageKey: 1);  
  int _pageNumber = 1;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }   

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }  

  Future<void> _fetchPage(int pageKey) async {
    try {
      await _availableCoursesProvider?.getAvailableCourses(pageNumber: _pageNumber);
      final newItems = _availableCoursesProvider?.newAvailableCourses;
      _pageNumber++;
      final isLastPage = newItems!.length < AppConstants.availableCoursesResultsPerPage;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }
  
  Widget _showAvailableCourses() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 60.0, 15.0, 0.0), 
      child: Column(
        children: [
          Expanded(
            child: PagedListView<int, CourseModel>(
              padding: const EdgeInsets.all(0),
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<CourseModel>(
                itemBuilder: (context, item, index) {
                  final String id = item.id as String;
                  final DateTime startDateTime = item.startDateTime as DateTime;
                  final String fieldName = _availableCoursesProvider?.getFieldName(item) as String;
                  final String courseTypeText = _availableCoursesProvider?.getCourseTypeText(item) as String;
                  final String mentorsNames = _availableCoursesProvider?.getMentorsNames(item) as String;
                  final List<Subfield> mentorsSubfields = _availableCoursesProvider?.getMentorsSubfields(item) as List<Subfield>;
                  final List<CourseStudent> students = item.students as List<CourseStudent>;
                  final String courseScheduleText = _availableCoursesProvider?.getCourseScheduleText(item) as String;
                  final List<ColoredText> joinCourseText = _availableCoursesProvider?.getJoinCourseText(item) as List<ColoredText>;
                  return AvailableCourse(
                    id: id,
                    startDateTime: startDateTime,
                    fieldName: fieldName,
                    courseTypeText: courseTypeText,
                    mentorsNames: mentorsNames,
                    mentorsSubfields: mentorsSubfields,
                    students: students,
                    scheduleText: courseScheduleText,
                    joinText: joinCourseText,
                    onJoin: _joinCourse
                  );
                },
                firstPageProgressIndicatorBuilder: (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                  child: Loader()
                ),
                newPageProgressIndicatorBuilder: (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Loader(),
                ),
                noItemsFoundIndicatorBuilder: (_) => _showNoItemsFoundIndicator()
              )
            ),
          ),
        ],
      )
    );
  }

  Future<CourseResult> _joinCourse(String courseId) async {
    CourseModel? course = CourseModel();
    NextLessonStudent? nextLesson;
    try {
      course = await _availableCoursesProvider?.joinCourse(courseId);
      nextLesson = await _availableCoursesProvider?.getNextLesson();
    } on ErrorModel catch(error) {
      _pageNumber = 1;
      _pagingController.refresh();
      throw(error);
    }
    CourseResult courseResult = CourseResult(course: course, nextLesson: nextLesson);
    return courseResult;
  }

  Widget _showNoItemsFoundIndicator() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        padding: const EdgeInsets.only(top: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'student_course.no_courses_found'.tr(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1.4
              )
            )
          ]
        )
      )
    );
  }

  Widget _showTitle() {
    return Center(
      child: Text(
        'student_course.available_courses_title'.tr(),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _goToFilters() async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute<bool>(builder: (_) => AvailableCoursesFiltersView())
    );    
    if (shouldRefresh == true) {
      _pageNumber = 1;
      _pagingController.refresh();    
    };
  }
  
  Future<bool> _onWillPop(BuildContext context) async {
    _availableCoursesProvider?.resetValues();
    return true;
  }  

  @override
  Widget build(BuildContext context) {
    _availableCoursesProvider = Provider.of<AvailableCoursesViewModel>(context);

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Stack(
        children: <Widget>[
          const BackgroundGradient(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: _showTitle(),
              backgroundColor: Colors.transparent,          
              elevation: 0.0,
              leading: GestureDetector(
                onTap: () async { 
                  _onWillPop(context);
                  Navigator.pop(context);
                },
                child: Platform.isIOS ? Icon(
                  Icons.arrow_back_ios_new
                ) : Icon(
                  Icons.arrow_back
                )
              ),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      _goToFilters();
                    },
                    child: Icon(
                      Icons.tune,
                      size: 26.0
                    )
                  )
                )
              ]
            ),
            extendBodyBehindAppBar: true,
            body: _showAvailableCourses()
          )
        ],
      ),
    );
  }
}
