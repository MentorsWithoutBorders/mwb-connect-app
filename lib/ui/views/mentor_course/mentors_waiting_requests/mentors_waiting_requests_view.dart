import 'dart:io' show Platform;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/field_model.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/mentor_waiting_request_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/models/mentor_parternship_result_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course/mentors_waiting_requests_view_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests_filters/mentors_waiting_requests_filters_view.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests/widgets/mentor_waiting_request_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class MentorsWaitingRequestsView extends StatefulWidget {
  const MentorsWaitingRequestsView({Key? key, @required this.field, @required this.courseTypes, @required this.mentorPartnershipRequest})
    : super(key: key);
    
  final Field? field;
  final List<CourseType>? courseTypes;
  final MentorPartnershipRequestModel? mentorPartnershipRequest;

  @override
  State<StatefulWidget> createState() => _MentorsWaitingRequestsViewState();
}

class _MentorsWaitingRequestsViewState extends State<MentorsWaitingRequestsView> {
  MentorsWaitingRequestsViewModel? _mentorsWaitingRequestsProvider;
  final PagingController<int, MentorWaitingRequest> _pagingController =
        PagingController(firstPageKey: 1);  
  int _pageNumber = 1;
  bool _isAddingMentorWaitingRequest = false;

  @override
  void initState() {
    _mentorsWaitingRequestsProvider = Provider.of<MentorsWaitingRequestsViewModel>(context, listen: false);
    _mentorsWaitingRequestsProvider?.fields = [widget.field as Field];
    _mentorsWaitingRequestsProvider?.setCourseTypes(widget.courseTypes as List<CourseType>);
    _mentorsWaitingRequestsProvider?.setFilterField(widget.field as Field);    
    _mentorsWaitingRequestsProvider?.filterCourseType = _mentorsWaitingRequestsProvider!.getCourseTypeById(widget.mentorPartnershipRequest?.courseType?.id);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }  

  Future<void> _fetchPage(int pageKey) async {
    CourseType? courseType = widget.mentorPartnershipRequest?.courseType;
    try {
      await _mentorsWaitingRequestsProvider!.getMentorsWaitingRequests(courseType: courseType, pageNumber: _pageNumber);
      final newItems = _mentorsWaitingRequestsProvider?.newMentorsWaitingRequests;
      _pageNumber++;
      final isLastPage = newItems!.length < AppConstants.availablePartnersResultsPerPage;
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
  
  void _afterLayout(_) { 
    _mentorsWaitingRequestsProvider?.setSubfieldOptionId(null);
    _mentorsWaitingRequestsProvider?.setAvailabilityOptionId(null);
  }

  Widget _showMentorsWaitingRequests() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final CourseMentor? selectedPartnerMentor = _mentorsWaitingRequestsProvider?.selectedPartnerMentor;
    final String? subfieldOptionId = _mentorsWaitingRequestsProvider?.subfieldOptionId;
    final String? availabilityOptionId = _mentorsWaitingRequestsProvider?.availabilityOptionId;
    final String? courseDayOfWeek = _mentorsWaitingRequestsProvider?.selectedPartnerMentor?.availabilities![0].dayOfWeek;
    final List<Subfield> mentorSubfields = widget.mentorPartnershipRequest?.mentor?.field?.subfields as List<Subfield>;
    final List<String>? courseHoursList = _mentorsWaitingRequestsProvider?.buildHoursList();
    return Stack(
      children: [
        if (_isAddingMentorWaitingRequest) Loader(),
        if (!_isAddingMentorWaitingRequest) Padding(
          padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 60.0, 15.0, 0.0), 
          child: Column(
            children: [
              _showWaitPartnershipText(),
              Expanded(
                child: PagedListView<int, MentorWaitingRequest>(
                  padding: const EdgeInsets.all(0),
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<MentorWaitingRequest>(
                    itemBuilder: (context, item, index) {
                      final String courseTypeText = _mentorsWaitingRequestsProvider?.getCourseTypeText(item) as String;
                      return MentorWaitingRequestItem(
                        partnerMentor: item.mentor,
                        selectedPartnerMentor: selectedPartnerMentor,
                        courseTypeText: courseTypeText,
                        subfieldOptionId: subfieldOptionId,
                        availabilityOptionId: availabilityOptionId,
                        courseDayOfWeek: courseDayOfWeek,
                        mentorSubfields: mentorSubfields,
                        courseHoursList: courseHoursList,
                        getSubfieldItemId: _mentorsWaitingRequestsProvider?.getSubfieldItemId,
                        getAvailabilityItemId: _mentorsWaitingRequestsProvider?.getAvailabilityItemId,
                        onSelectSubfield: _setSubfieldOptionId,
                        onSelectAvailability: _setAvailabilityOptionId,
                        onSelectMentor: _setSelectedPartnerMentor,
                        onSendRequest: _sendMentorPartnershipRequest,
                        onGoBack: _goBack,
                        getErrorMessage: _getErrorMessage
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
        ),
      ],
    );
  }

  Widget _showWaitPartnershipText() {
    String text = 'mentor_course.wait_mentor_partnership_request_text'.tr() + ' ';
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 15.0),
      child: RichText(
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.4
          ),
          children: <TextSpan>[
            TextSpan(
              text: text
            ),
            TextSpan(
              text: 'common.clicking_here'.tr(),
              style: const TextStyle(
                color: Colors.yellow,
                decoration: TextDecoration.underline
              ),
              recognizer: TapGestureRecognizer()..onTap = () async {
                await _addMentorWaitingRequest();
              } 
            ),
            TextSpan(
              text: '.'
            )
          ]
        )
      ),
    );
  }
  
  Future<void> _addMentorWaitingRequest() async {
    setState(() {
      _isAddingMentorWaitingRequest = true;
    });    
    await _mentorsWaitingRequestsProvider?.addMentorWaitingRequest(widget.mentorPartnershipRequest?.courseType as CourseType);
    _goBack();
  }

  void _setSubfieldOptionId(String? subfieldOptionId) {
    _mentorsWaitingRequestsProvider?.setSubfieldOptionId(subfieldOptionId);
  }

  void _setAvailabilityOptionId(String? availabilityOptionId) {
    _mentorsWaitingRequestsProvider?.setAvailabilityOptionId(availabilityOptionId);
  }

  void _setSelectedPartnerMentor(CourseMentor? mentor) {
    _mentorsWaitingRequestsProvider?.setSelectedPartnerMentor(mentor: null);
    _mentorsWaitingRequestsProvider?.setSelectedPartnerMentor(mentor: mentor);
  }

  Future<void> _sendMentorPartnershipRequest(String mentorSubfieldId, String courseStartTime) async {
    CourseMentor mentor = widget.mentorPartnershipRequest?.mentor as CourseMentor;
    await _mentorsWaitingRequestsProvider?.sendMentorPartnershipRequest(mentor, mentorSubfieldId, courseStartTime);
  }

  void _goBack() {
    MentorPartnershipRequestModel? mentorPartnershipRequest = _mentorsWaitingRequestsProvider?.mentorPartnershipRequest;
    MentorWaitingRequest? mentorWaitingRequest = _mentorsWaitingRequestsProvider?.mentorWaitingRequest;
    _mentorsWaitingRequestsProvider?.resetValues();
    MentorPartnershipResult? mentorPartnershipResult = MentorPartnershipResult(
      mentorPartnershipRequest: mentorPartnershipRequest,
      mentorWaitingRequest: mentorWaitingRequest
    );
    Navigator.pop(context, mentorPartnershipResult);
  }

  String _getErrorMessage(CourseMentor mentor) {
    return _mentorsWaitingRequestsProvider?.getErrorMessage(mentor) as String;
  }

  Widget _showNoItemsFoundIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 0.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'available_mentors.no_mentors_found'.tr(),
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
        ),
      )
    );
  }

  Widget _showTitle() {
    return Center(
      child: Text(
        'available_mentors.title'.tr(),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _goToFilters() async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute<bool>(builder: (_) => MentorsWaitingRequestsFiltersView())
    );    
    if (shouldRefresh == true) {
      _pageNumber = 1;
      _pagingController.refresh();    
    };
  }
  
  Future<bool> _onWillPop(BuildContext context) async {
    _mentorsWaitingRequestsProvider?.resetValues();
    return true;
  }  

  @override
  Widget build(BuildContext context) {
    _mentorsWaitingRequestsProvider = Provider.of<MentorsWaitingRequestsViewModel>(context);

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
            body: _showMentorsWaitingRequests()
          )
        ],
      ),
    );
  }
}
