import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/course_mentor_model.dart';
import 'package:mwb_connect_app/core/models/course_type_model.dart';
import 'package:mwb_connect_app/core/models/subfield_model.dart';
import 'package:mwb_connect_app/core/models/mentor_waiting_request_model.dart';
import 'package:mwb_connect_app/core/models/mentor_partnership_request_model.dart';
import 'package:mwb_connect_app/core/viewmodels/mentor_course/mentors_waiting_requests_view_model.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests_filters/mentors_waiting_requests_filters_view.dart';
import 'package:mwb_connect_app/ui/views/mentor_course/mentors_waiting_requests/widgets/mentor_waiting_request_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class MentorsWaitingRequestsView extends StatefulWidget {
  const MentorsWaitingRequestsView({Key? key, required this.mentorPartnershipRequest})
    : super(key: key);
    
  final MentorPartnershipRequestModel mentorPartnershipRequest;

  @override
  State<StatefulWidget> createState() => _MentorsWaitingRequestsViewState();
}

class _MentorsWaitingRequestsViewState extends State<MentorsWaitingRequestsView> {
  MentorsWaitingRequestsViewModel? _mentorsWaitingRequestsProvider;
  final PagingController<int, MentorWaitingRequest> _pagingController =
        PagingController(firstPageKey: 0);  
  int _pageNumber = 1;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(_afterLayout);
  }  

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }  

  Future<void> _fetchPage(int pageKey) async {
    CourseType? courseType = widget.mentorPartnershipRequest.courseType;
    try {
      await _mentorsWaitingRequestsProvider?.getMentorsWaitingRequests(courseType: courseType, pageNumber: _pageNumber);
      final newItems = _mentorsWaitingRequestsProvider?.newMentorsWaitingRequests;
      _pageNumber++;
      final isLastPage = newItems!.length < AppConstants.availableMentorsResultsPerPage;
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
    final List<Subfield> mentorSubfields = widget.mentorPartnershipRequest.mentor?.field?.subfields as List<Subfield>;
    final List<String>? courseHoursList = _mentorsWaitingRequestsProvider?.buildHoursList();
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 60.0, 15.0, 0.0), 
      child: PagedListView<int, MentorWaitingRequest>(
        padding: const EdgeInsets.all(0),
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<MentorWaitingRequest>(
          itemBuilder: (context, item, index) {
            return MentorWaitingRequestItem(
              partnerMentor: item.mentor,
              selectedPartnerMentor: selectedPartnerMentor,
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
      )
    );
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
    CourseMentor mentor = widget.mentorPartnershipRequest.mentor as CourseMentor;
    await _mentorsWaitingRequestsProvider?.sendMentorPartnershipRequest(mentor, mentorSubfieldId, courseStartTime);
  }

  void _goBack() {
    Navigator.pop(context, _mentorsWaitingRequestsProvider?.mentorPartnershipRequest);
  }

  String _getErrorMessage(CourseMentor mentor) {
    return _mentorsWaitingRequestsProvider?.getErrorMessage(mentor) as String;
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
        )
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
