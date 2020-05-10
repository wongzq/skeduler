import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';

// --------------------------------------------------------------------------------
// Route Arguments Template
// --------------------------------------------------------------------------------

abstract class _RouteArgsTemplate {
  // properties
  Group _group;
  Member _me;
  Member _member;
  List<String> _axisCustom;
  void Function(List<String>) _valSetAxisCustom;

  // constructors
  _RouteArgsTemplate();

  _RouteArgsTemplate.group(
    this._group,
  );

  _RouteArgsTemplate.member(
    this._me,
    this._member,
  );

  _RouteArgsTemplate.reorderAxisCustom(
    this._axisCustom,
    this._valSetAxisCustom,
  );
}

// --------------------------------------------------------------------------------
// Route Arguments related classes
// --------------------------------------------------------------------------------

class RouteArgs extends _RouteArgsTemplate {
  RouteArgs() : super();
}

class RouteArgsGroup extends _RouteArgsTemplate {
  RouteArgsGroup({@required Group group}) : super.group(group);

  get group => this._group;
}

class RouteArgsEditMember extends _RouteArgsTemplate {
  RouteArgsEditMember({
    @required Member me,
    @required Member member,
  }) : super.member(me, member);

  get me => this._me;
  get member => this._member;
}

class RouteArgsReorderAxisCustom extends _RouteArgsTemplate {
  RouteArgsReorderAxisCustom({
    @required List<String> axisCustom,
    @required void Function(List<String>) valSetAxisCustom,
  }) : super.reorderAxisCustom(axisCustom, valSetAxisCustom);

  get axisCustom => this._axisCustom;
  get valSetAxisCustom => this._valSetAxisCustom;
}
