import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/group_data/time.dart';

class Member {
  // properties
  String _email;
  String _name;
  String _nickname;
  String _description;

  MemberRole _role;
  ColorShade _colorShade;

  List<Time> _times;

  // constructors
  Member({
    @required String id,
    String name,
    String nickname,
    String description,
    MemberRole role,
    ColorShade colorShade,
    List<Time> times,
  }) {
    _email = id;
    _name = name;
    _nickname = nickname;
    _description = description;
    _role = role;
    _colorShade = colorShade;
    _times = times;
  }

  // getter methods
  String get id => _email;
  String get name => _name;
  String get nickname => _nickname;
  String get display => _nickname ?? _name ?? _email;
  String get description => _description;
  MemberRole get role => _role;
  String get roleStr => memberRoleStr(_role);
  IconData get roleIcon => _memberRoleIcon(_role);
  ColorShade get colorShade => _colorShade;
  List<Time> get times => _times;
}

enum MemberRole {
  pending,
  dummy,
  member,
  admin,
  owner,
}

String memberRoleStr(MemberRole role) {
  switch (role) {
    case MemberRole.pending:
      return 'Pending';
      break;
    case MemberRole.dummy:
      return 'Dummy';
      break;
    case MemberRole.member:
      return 'Member';
      break;
    case MemberRole.admin:
      return 'Admin';
      break;
    case MemberRole.owner:
      return 'Owner';
      break;
    default:
      return '';
      break;
  }
}

IconData _memberRoleIcon(MemberRole role) {
  switch (role) {
    case MemberRole.pending:
      return FontAwesomeIcons.clock;
      break;
    case MemberRole.dummy:
      return FontAwesomeIcons.user;
      break;
    case MemberRole.member:
      return FontAwesomeIcons.userAlt;
      break;
    case MemberRole.admin:
      return FontAwesomeIcons.userCog;
      break;
    case MemberRole.owner:
      return FontAwesomeIcons.userTie;
      break;
    default:
      return Icons.close;
      break;
  }
}
