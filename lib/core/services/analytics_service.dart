import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class AnalyticsService {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);  

  void identifyUser(String userId, String name, String email) async {
    // Segment.identify(
    //   userId: userId,
    //   traits: {
    //     'name': name,
    //     'email': email
    //   }
    // );
    // //Firebase Analytics
    // await analytics.setUserId(userId);
    // await analytics.setUserProperty(name: 'name', value: name);
    // await analytics.setUserProperty(name: 'email', value: email);
  }
  
  void resetUser() {
    // Segment.reset();
    // //Firebase Analytics
    // analytics.setUserId(null);    
  }   
  
  void sendScreenName(String name) {
    // Segment.screen(
    //   screenName: name
    // );
    // //Firebase Analytics
    // analytics.setCurrentScreen(
    //   screenName: name
    // );    
  }

  void sendEvent({String eventName, dynamic properties}) {
    // Segment.track(
    //   eventName: eventName,
    //   properties: properties,
    // );
    //Firebase Analytics
    // analytics.logEvent(
    //   name: eventName,
    //   parameters: properties,
    // );    
  }

}