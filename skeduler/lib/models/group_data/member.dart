// import 'package:flutter/material.dart';
// import 'package:skeduler/models/availability.dart';

import 'package:skeduler/models/auxiliary/color_shade.dart';

class Member {
//   /// properties
  String _email;
  String _name;
  String _nickname;
  String _description;
  
  MemberRole _role;
  ColorShade _colorShade;
  
  // List<Availability> _availability;
}

enum MemberRole {
  pending,
  member,
  admin,
  owner,
}
