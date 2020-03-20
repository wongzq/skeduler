import 'package:flutter/material.dart';

class User {
  final String uid;

  User({this.uid});
}

class UserData {
  final String uid;
  final String email;
  final String name;
  final Color color;

  UserData({this.uid, this.email, this.name, this.color});
}
