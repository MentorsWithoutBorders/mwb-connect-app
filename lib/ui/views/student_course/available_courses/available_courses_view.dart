import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_model.dart';
import 'package:mwb_connect_app/core/viewmodels/student_course_view_model.dart';
import 'package:mwb_connect_app/ui/views/student_course/available_courses/widgets/available_course_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class AvailableCoursesView extends StatefulWidget {
  const AvailableCoursesView({Key? key, this.fieldId})
    : super(key: key);
    
  final String? fieldId;

  @override
  State<StatefulWidget> createState() => _AvailableCoursesViewState();
}

class _AvailableCoursesViewState extends State<AvailableCoursesView> {
  StudentCourseViewModel? _studentCourseProvider;
  final PagingController<int, CourseModel> _pagingController =
        PagingController(firstPageKey: 0);  
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
      await _studentCourseProvider?.getAvailableCourses(pageNumber: _pageNumber);
      final newItems = _studentCourseProvider?.newAvailableCourses;
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
      child: PagedListView<int, CourseModel>(
        padding: const EdgeInsets.all(0),
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<CourseModel>(
          itemBuilder: (context, item, index) => AvailableCourse(
            course: _studentCourseProvider?.course,
          ),
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
      )
    );
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
        'student_course.find_course'.tr(),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    _studentCourseProvider = Provider.of<StudentCourseViewModel>(context);

    return Stack(
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
          body: _showAvailableCourses()
        )
      ],
    );
  }
}
