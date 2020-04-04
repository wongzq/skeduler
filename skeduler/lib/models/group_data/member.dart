import 'package:flutter/foundation.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/group_data/time.dart';

enum MemberRole {
  pending,
  member,
  admin,
  owner,
}

class Member {
  /// properties
  String _email;
  String _name;
  String _nickname;
  String _description;

  MemberRole _role;
  ColorShade _colorShade;

  List<Time> _times;

  /// constructor
  Member({
    @required String email,
    String name,
    String nickname,
    String description,
    MemberRole role,
    ColorShade colorShade,
    List<Time> times,
  }) {
    _email = email;
    _name = name;
    _nickname = nickname;
    _description = description;
    _role = role;
    _colorShade = colorShade;
    _times = times;
  }

  /// getter methods
  String get email => _email;
  String get name => _name;
  String get nickname => _nickname;
  String get description => _description;
  MemberRole get role => _role;
  ColorShade get colorShade => _colorShade;
  List<Time> get times => _times;
}
