import 'package:flutter/material.dart';

class NavigationService{
  GlobalKey<NavigatorState> navigationKey;

  static NavigationService instance = NavigationService();

  NavigationService(){
    navigationKey = GlobalKey<NavigatorState>();
  }

  BuildContext getCurrentContext(){
    return navigationKey.currentContext;
  }  

  Future<dynamic> navigateToReplacement(String _rn){
    return navigationKey.currentState.pushReplacementNamed(_rn);
  }

  Future<dynamic> navigateTo(String _rn){
    return navigationKey.currentState.pushNamed(_rn);
  }
 
  Future<dynamic> navigateToRoute(MaterialPageRoute _rn){
    return navigationKey.currentState.push(_rn);
  }

  goback(){
    return navigationKey.currentState.pop();
  }
}