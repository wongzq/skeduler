import 'package:flutter/material.dart';

class User {
  final String uid;

  User({this.uid});
}

class UserData {
  String _uid;
  String _email;
  String _name;

  UserData({
    uid = '',
    email = '',
    name = '',
  }) {
    _uid = uid;
    _email = email;
    _name = name;
  }

  // getter methods
  String get uid => _uid;
  String get email => _email;
  String get name => _name;

  // // setter methods
  // void update({
  //   uid,
  //   email,
  //   name,
  // }) {
  //   if (uid != null) _uid = uid;
  //   if (email != null) _email = email;
  //   if (name != null) _name = name;
  // }

  // set uid(String value) => _uid = value;
  // set email(String value) => _email = value;
  // set name(String value) => _name = value;
}
