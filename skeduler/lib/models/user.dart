import 'package:flutter/material.dart';

class User extends ChangeNotifier {
  final String uid;

  User({this.uid});
}

class UserData {
  final String uid;
  final String email;
  final String name;
  final bool dark;
  final String color;

  UserData({
    this.uid = '',
    this.email = '',
    this.name = '',
    this.dark = false,
    this.color = '',
  });
}
