import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_mocks/cloud_firestore_mocks.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class Api {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final MockFirestoreInstance _dbTest = MockFirestoreInstance();
  CollectionReference _ref;
  String userId;

  void _setRef(String path, bool isForUser) {
    final LocalStorageService storageService = locator<LocalStorageService>();
    userId = storageService.userId;
    if (userId != 'test_user') {
      _ref = isForUser ? _db.collection('users').doc(userId).collection(path) : _db.collection(path);
    } else {
      _ref = isForUser ? _dbTest.collection('users').doc(userId).collection(path) : _dbTest.collection(path);
    }
  }

  Future<QuerySnapshot> getDataCollection({String path, bool isForUser = false}) {
    _setRef(path, isForUser);      
    return _ref.get();
  }

  Stream<QuerySnapshot> streamDataCollection({String path, bool isForUser = false}) {
    _setRef(path, isForUser);    
    return _ref.snapshots();
  }

  Future<DocumentSnapshot> getDocumentById({String path, bool isForUser = false, String id}) {
    _setRef(path, isForUser);
    return _ref.doc(id).get();
  }

  Future<void> removeDocument({String path, bool isForUser = false, String id}){
    _setRef(path, isForUser);   
    return _ref.doc(id).delete();
  }

  Future<void> removeSubCollection({String path, bool isForUser = false}){
    _setRef(path, isForUser);   
    return _ref.get().then((QuerySnapshot snapshot) {
      for (final DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    }); 
  }  

  Future<DocumentReference> addDocument({String path, bool isForUser = false, Map data}) {
    _setRef(path, isForUser);     
    return _ref.add(data);
  }

  Future<void> setDocument({String path, bool isForUser = false, Map data, String id}) {
    _setRef(path, isForUser);
    return _ref.doc(id).set(data);
  }  
  
  Future<void> updateDocument({String path, bool isForUser = false, Map data, String id}) {
    _setRef(path, isForUser);     
    return _ref.doc(id).update(data);
  }

}