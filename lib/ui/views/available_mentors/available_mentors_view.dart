import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mwb_connect_app/utils/constants.dart';
import 'package:mwb_connect_app/core/models/user_model.dart';
import 'package:mwb_connect_app/core/viewmodels/available_mentors_view_model.dart';
import 'package:mwb_connect_app/ui/views/available_mentors_filters/available_mentors_filters_view.dart';
import 'package:mwb_connect_app/ui/views/available_mentors/widgets/available_mentor_widget.dart';
import 'package:mwb_connect_app/ui/widgets/background_gradient_widget.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';

class AvailableMentorsView extends StatefulWidget {
  const AvailableMentorsView({Key? key})
    : super(key: key);   

  @override
  State<StatefulWidget> createState() => _AvailableMentorsViewState();
}

class _AvailableMentorsViewState extends State<AvailableMentorsView> {
  AvailableMentorsViewModel? _availableMentorsProvider;
  final PagingController<int, User> _pagingController =
        PagingController(firstPageKey: 0);  
  int _pageNumber = 1;

  @override
  void initState() {
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
    try {
      await _availableMentorsProvider?.getAvailableMentors(pageNumber: _pageNumber);
      final newItems = _availableMentorsProvider?.newAvailableMentors;
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
    _availableMentorsProvider?.setAvailabilityOptionId(null);
    _availableMentorsProvider?.setSubfieldOptionId(null);
    _availableMentorsProvider?.setErrorMessage('');    
  }  

  Widget _showAvailableMentors() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, statusBarHeight + 60.0, 15.0, 0.0), 
      child: PagedListView<int, User>(
        padding: const EdgeInsets.all(0),
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<User>(
          itemBuilder: (context, item, index) => AvailableMentor(
            mentor: item,
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
      MaterialPageRoute<bool>(builder: (_) => AvailableMentorsFiltersView())
    );    
    if (shouldRefresh == true) {
      _pageNumber = 1;
      _pagingController.refresh();    
    };
  }
  
  Future<bool> _onWillPop(BuildContext context) async {
    _availableMentorsProvider?.resetValues();
    return true;
  }  

  @override
  Widget build(BuildContext context) {
    _availableMentorsProvider = Provider.of<AvailableMentorsViewModel>(context);

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
            body: _showAvailableMentors()
          )
        ],
      ),
    );
  }
}
