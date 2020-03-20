import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skeduler/models/user.dart';

class DatabaseService {
  // properties
  final String uid;

  // constructor
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference usersCollection =
      Firestore.instance.collection('users');

  // update user data
  Future updateUserData({String email, String name, Color color}) async {
    return await usersCollection.document(uid).setData({
      'email': email,
      'name': name,
      'color': color,
    });
  }

  // get user data
  Stream<UserData> get userData {
    return usersCollection.document(uid).snapshots().map(_userFromSnapshot);
  }

  // snapshot user data
  UserData _userFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      email: snapshot.data['email'],
      name: snapshot.data['name'],
      color: snapshot.data['color'],
    );
  }
}
