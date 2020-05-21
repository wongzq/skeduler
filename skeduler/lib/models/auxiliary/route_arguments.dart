import 'package:flutter/material.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/firestore/subject.dart';

// --------------------------------------------------------------------------------
// Route Arguments Template
// --------------------------------------------------------------------------------

abstract class _RouteArgsTemplate {
  // properties
  Group _group;
  Member _member;
  Subject _subject;
  List<String> _axisCustom;
  void Function(List<String>) _valSetAxisCustom;

  // constructors
  _RouteArgsTemplate();

  _RouteArgsTemplate.group(
    this._group,
  );

  _RouteArgsTemplate.member(
    this._member,
  );

  _RouteArgsTemplate.subject(
    this._subject,
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
    @required Member member,
  }) : super.member(member);

  get member => this._member;
}

class RouteArgsEditSubject extends _RouteArgsTemplate {
  RouteArgsEditSubject({
    @required Subject subject,
  }) : super.subject(subject);

  get subject => this._subject;
}

class RouteArgsReorderAxisCustom extends _RouteArgsTemplate {
  RouteArgsReorderAxisCustom({
    @required List<String> axisCustom,
    @required void Function(List<String>) valSetAxisCustom,
  }) : super.reorderAxisCustom(axisCustom, valSetAxisCustom);

  get axisCustom => this._axisCustom;
  get valSetAxisCustom => this._valSetAxisCustom;
}
