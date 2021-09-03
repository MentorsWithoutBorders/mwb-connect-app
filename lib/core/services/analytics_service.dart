class AnalyticsService {

  Future<void> identifyUser(String userId, String name, String email) async {
    // Segment.identify(
    //   userId: userId,
    //   traits: {
    //     'name': name,
    //     'email': email
    //   }
    // );
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
  }

  void sendEvent({required String eventName, dynamic properties}) {
    // Segment.track(
    //   eventName: eventName,
    //   properties: properties,
    // );
  }

}