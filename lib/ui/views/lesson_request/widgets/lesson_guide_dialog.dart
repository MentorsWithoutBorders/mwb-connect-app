import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mwb_connect_app/utils/colors.dart';
import 'package:mwb_connect_app/core/models/guide_tutorial_model.dart';
import 'package:mwb_connect_app/core/models/guide_recommendation_model.dart';
import 'package:mwb_connect_app/core/viewmodels/lesson_request_view_model.dart';
import 'package:mwb_connect_app/ui/widgets/loader_widget.dart';
import 'package:mwb_connect_app/ui/widgets/bullet_point_widget.dart';

class LessonGuideDialog extends StatefulWidget {
  const LessonGuideDialog({Key key})
    : super(key: key);  

  @override
  State<StatefulWidget> createState() => _LessonGuideDialogState();
}

class _LessonGuideDialogState extends State<LessonGuideDialog> {
  LessonRequestViewModel _lessonRequestProvider;
  final ScrollController _scrollController = ScrollController();    
  bool _isLessonGuideRetrieved = false;

  Widget _showLessonGuideDialog() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 20.0),
      child: Wrap(
        children: <Widget>[
          _showTitle(),
          _showLessonGuide(),
          _showCloseButton()
        ]
      )
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Center(
        child: Text(
          'lesson_request.lesson_guide'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          )
        )
      ),
    );
  }

  Widget _showLessonGuide() {
    List<GuideTutorial> guideTutorials = _lessonRequestProvider.guideTutorials != null ? _lessonRequestProvider.guideTutorials : [];
    List<GuideRecommendation> guideRecommendations = _lessonRequestProvider.guideRecommendations != null ? _lessonRequestProvider.guideRecommendations : [];
    List<Widget> lessonGuideWidgets = [];
    Widget guideTutorialsText = Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        'lesson_request.lesson_guide_tutorials_text'.tr(),
        style: const TextStyle(
          fontSize: 12.0,
          color: AppColors.DOVE_GRAY,
          height: 1.5
        )
      )
    );
    if (guideTutorials.length > 0) {
      lessonGuideWidgets.add(guideTutorialsText);
    }
    for (GuideTutorial guideTutorial in guideTutorials) {
      Widget guideTutorialWidget = Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              guideTutorial.skills.join(', '),
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                height: 1.5
              )
            ),
            _showGuideLines(guideTutorial.tutorialUrls, true)         
          ]
        ),
      );
      lessonGuideWidgets.add(guideTutorialWidget);
    }
    for (GuideRecommendation guideRecommendations in guideRecommendations) {
      Widget guideRecommendationWidget = Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              guideRecommendations.type + ' ' + 'lesson_request.recommendations'.tr() + ':',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                height: 1.5
              )
            ),
            _showGuideLines(guideRecommendations.recommendations, false)         
          ]
        ),
      );
      lessonGuideWidgets.add(guideRecommendationWidget);
    }    

    if (_isLessonGuideRetrieved) {
      return Container(
        height: 300.0,
        padding: const EdgeInsets.only(bottom: 20.0),
        child: DraggableScrollbar(
          controller: _scrollController,
          child: ListView(
            padding: const EdgeInsets.only(right: 10.0),
            controller: _scrollController,
            children: lessonGuideWidgets
          ),
          heightScrollThumb: 150.0,
          backgroundColor: AppColors.SILVER,
          scrollThumbBuilder: (
            Color backgroundColor,
            Animation<double> thumbAnimation,
            Animation<double> labelAnimation,
            double height, {
            Text labelText,
            BoxConstraints labelConstraints
          }) {
            return FadeTransition(
              opacity: thumbAnimation,
              child: Container(
                height: height,
                width: 5.0,
                color: backgroundColor,
              )
            );
          }        
        )
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 30.0, bottom: 50.0),
        child: Loader(color: AppColors.DOVE_GRAY)
      );
    }
  }

  Widget _showGuideLines(List<String> guideLines, bool isGuideTutorial) {
    return Container(
      padding: const EdgeInsets.only(top: 10.0),
      child: ListView.builder(
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: guideLines.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 30.0,
                  padding: const EdgeInsets.only(top: 5.0),
                  child: BulletPoint()
                ),
                if (isGuideTutorial) Expanded(
                  child: InkWell(
                    child: Text(
                      '${guideLines[index]}',
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.blue,
                        decoration: TextDecoration.underline
                      )
                    ),
                    onTap: () async {
                      await _launchUrl(guideLines[index]);
                    }                     
                  )
                ),
                if (!isGuideTutorial) Expanded(
                  child: InkWell(
                    child: Text(
                      '${guideLines[index]}',
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: AppColors.DOVE_GRAY,
                      )
                    )
                  )
                )
              ],
            ),
          );
        }
      )
    );
  }
  
  Future<void> _launchUrl(String url) async {
    await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }
  
  Widget _showCloseButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: AppColors.PACIFIC_BLUE,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
          ),
          padding: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 5.0),
        ),
        child: Text(
          'common.close'.tr(),
          style: const TextStyle(color: Colors.white)
        ),
        onPressed: () {
          Navigator.pop(context);
        }
      ),
    );
  }
  
  Future<void> _getLessonGuide() async {
    if (!_isLessonGuideRetrieved) {
      await _lessonRequestProvider.getGuideTutorials();
      await _lessonRequestProvider.getGuideRecommendations();
      _isLessonGuideRetrieved = true;
    } 
  }
  
  @override
  Widget build(BuildContext context) {
    _lessonRequestProvider = Provider.of<LessonRequestViewModel>(context);

    return FutureBuilder<void>(
      future: _getLessonGuide(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        return _showLessonGuideDialog();
      }
    );
  }
}