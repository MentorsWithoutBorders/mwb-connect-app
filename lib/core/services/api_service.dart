import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mwb_connect_app/service_locator.dart';
import 'package:mwb_connect_app/core/services/local_storage_service.dart';

class Api {
  final Firestore _db = Firestore.instance;
  CollectionReference _ref;

  _setRef(String path, bool isForUser) {
    LocalStorageService storageService = locator<LocalStorageService>();
    String userId = storageService.userId;
    _ref = isForUser ? _db.collection('users').document(userId).collection(path) : _db.collection(path);    
  }

  Future<QuerySnapshot> getDataCollection({String path, bool isForUser = false}) {
    _setRef(path, isForUser);      
    return _ref.getDocuments();
  }

  Stream<QuerySnapshot> streamDataCollection({String path, bool isForUser = false}) {
    _setRef(path, isForUser);    
    return _ref.snapshots();
  }

  Future<DocumentSnapshot> getDocumentById({String path, bool isForUser = false, String id}) {
    _setRef(path, isForUser);     
    return _ref.document(id).get();
  }

  Future<void> removeDocument({String path, bool isForUser = false, String id}){
    _setRef(path, isForUser);   
    return _ref.document(id).delete();
  }

  Future<void> removeSubCollection({String path, bool isForUser = false}){
    _setRef(path, isForUser);   
    return _ref.getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents){
        ds.reference.delete();
      };
    }); 
  }  

  Future<DocumentReference> addDocument({String path, bool isForUser = false, Map data}) {
    _setRef(path, isForUser);     
    return _ref.add(data);
  }

  Future setDocument({String path, bool isForUser = false, Map data, String id}) {
    _setRef(path, isForUser);
    _ref.document(id).setData(data);
  }  
  
  Future<void> updateDocument({String path, bool isForUser = false, Map data, String id}) {
    _setRef(path, isForUser);     
    return _ref.document(id).updateData(data) ;
  }

}