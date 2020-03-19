import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final String uid;

  DatabaseService({this.uid});

  // collection reference
  final CollectionReference usersCollection =
      Firestore.instance.collection('users');

  // update user's personal data
  Future updateUserData({String name, Color color}) async {
    return await usersCollection.document(uid).setData({
      'name': name,
      'color': color,
    });
  }
}
