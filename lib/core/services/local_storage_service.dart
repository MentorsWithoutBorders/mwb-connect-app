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

  bool get isMentor => _getFromDisk('isMentor');
  set isMentor(bool value) => _saveToDisk('isMentor', value);

  Map<String, dynamic> get tutorials => _getFromDisk('tutorials');
  set tutorials(Map<String, String> value) => _saveToDisk('tutorials', value);
  
  int get quizzesCount => _getFromDisk('quizzesCount');
  set quizzesCount(int value) => _saveToDisk('quizzesCount', value);
  
  int get quizzesRounds => _getFromDisk('quizzesRounds');
  set quizzesRounds(int value) => _saveToDisk('quizzesRounds', value);
  
  int get timeBetweenQuizzesRounds => _getFromDisk('timeBetweenQuizzesRounds');
  set timeBetweenQuizzesRounds(int value) => _saveToDisk('timeBetweenQuizzesRounds', value); 
  
  int get quizNumber => _getFromDisk('quizNumber');
  set quizNumber(int value) => _saveToDisk('quizNumber', value);

  bool get showQuizTimer => _getFromDisk('showQuizTimer');
  set showQuizTimer(bool value) => _saveToDisk('showQuizTimer', value);
  
  bool get notificationsEnabled => _getFromDisk('notificationsEnabled');
  set notificationsEnabled(bool value) => _saveToDisk('notificationsEnabled', value);  

  String get notificationsTime => _getFromDisk('notificationsTime');
  set notificationsTime(String value) => _saveToDisk('notificationsTime', value);    

  dynamic _getFromDisk(String key) {
    var value = _preferences.get(key);
    if (value is String && value !=null && value.indexOf('{') > -1) {
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
    if (content is Map<String, String>) {
      _preferences.setString(key, json.encode(content));
    }    
  }    
}