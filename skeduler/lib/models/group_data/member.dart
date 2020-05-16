import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/group_data/time.dart';

class Member {
  // properties
  String _docId;
  String _name;
  String _nickname;
  String _description;

  MemberRole _role;
  ColorShade _colorShade;

  List<Time> _times;

  // constructors
  Member({
    @required String docId,
    String name,
    String nickname,
    String description,
    MemberRole role,
    ColorShade colorShade,
    List<Time> times,
  }) {
    this._docId = docId;
    this._name = name;
    this._nickname = nickname;
    this._description = description;
    this._role = role;
    this._colorShade = colorShade;
    this._times = times;
  }

  // getter methods
  String get docId => this._docId;
  String get name => this._name;
  String get nickname => this._nickname;
  String get display => this._nickname ?? this._name ?? this._docId;
  String get description => this._description;
  MemberRole get role => this._role;
  String get roleStr => memberRoleStr(this._role);
  IconData get roleIcon => _memberRoleIcon(this._role);
  ColorShade get colorShade => this._colorShade;
  List<Time> get times => this._times;
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
