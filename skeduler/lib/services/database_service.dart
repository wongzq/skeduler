import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  // properties
  final String uid;

  // constructor
  DatabaseService({this.uid});

  // collection reference
  final CollectionReference usersCollection =
      Firestore.instance.collection('users');

  // update user's personal data
  Future updateUserData({String email, String name, Color color}) async {
    return await usersCollection.document(uid).setData({
      'email': email,
      'name': name,
      'color': color,
    });
  }
}
