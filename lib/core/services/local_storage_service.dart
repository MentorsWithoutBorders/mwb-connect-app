import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences _preferences;

  Future<LocalStorageService> init() async {
    _preferences = await SharedPreferences.getInstance();  
    return this;
  }

  String get userId => _getFromDisk('userId');
  set userId(String value) => _saveToDisk('userId', value);

  String get userEmail => _getFromDisk('userEmail');
  set userEmail(String value) => _saveToDisk('userEmail', value);
  
  String get userName => _getFromDisk('userName');
  set userName(String value) => _saveToDisk('userName', value);

  String get accessToken => _getFromDisk('accessToken');
  set accessToken(String value) => _saveToDisk('accessToken', value);
  
  String get refreshToken => _getFromDisk('refreshToken');
  set refreshToken(String value) => _saveToDisk('refreshToken', value);    

  bool get isMentor => _getFromDisk('isMentor');
  set isMentor(bool value) => _saveToDisk('isMentor', value);

  String get subfieldId => _getFromDisk('subfieldId');
  set subfieldId(String value) => _saveToDisk('subfieldId', value);     

  String get registeredOn => _getFromDisk('registeredOn');
  set registeredOn(String value) => _saveToDisk('registeredOn', value);    

  Map<String, dynamic> get tutorials => _getFromDisk('tutorials');
  set tutorials(Map<String, List<String>> value) => _saveToDisk('tutorials', value);
  
  int get quizzesStudentWeeklyCount => _getFromDisk('quizzesStudentWeeklyCount');
  set quizzesStudentWeeklyCount(int value) => _saveToDisk('quizzesStudentWeeklyCount', value);

  int get quizzesMentorWeeklyCount => _getFromDisk('quizzesMentorWeeklyCount');
  set quizzesMentorWeeklyCount(int value) => _saveToDisk('quizzesMentorWeeklyCount', value);  
  
  int get quizNumber => _getFromDisk('quizNumber');
  set quizNumber(int value) => _saveToDisk('quizNumber', value);

  bool get isLastStepAdded => _getFromDisk('isLastStepAdded');
  set isLastStepAdded(bool value) => _saveToDisk('isLastStepAdded', value);    

  bool get notificationsEnabled => _getFromDisk('notificationsEnabled');
  set notificationsEnabled(bool value) => _saveToDisk('notificationsEnabled', value);  

  String get notificationsTime => _getFromDisk('notificationsTime');
  set notificationsTime(String value) => _saveToDisk('notificationsTime', value);    

  dynamic _getFromDisk(String key) {
    Object value = _preferences.get(key);
    if (value is String && value != null && value.indexOf('{') == 0) {
      value = json.decode(value);
    }
    print('(TRACE) LocalStorageService:_getFromDisk. key: $key value: $value');
    return value;
  }  

  // updated _saveToDisk function that handles all types
  void _saveToDisk<T>(String key, T content){
    print('(TRACE) LocalStorageService:_saveToDisk. key: $key value: $content');

    if (content == null) {
      _preferences.remove(key);
    }
    if (content is String) {
      _preferences.setString(key, content);
    }
    if (content is bool) {
      _preferences.setBool(key, content);
    }
    if (content is int) {
      _preferences.setInt(key, content);
    }
    if (content is double) {
      _preferences.setDouble(key, content);
    }
    if (content is List<String>) {
      _preferences.setStringList(key, content);
    }
    if (content is Map<String, List<String>>) {
      _preferences.setString(key, json.encode(content));
    }    
  }    
}