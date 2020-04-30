import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/group.dart';

// --------------------------------------------------------------------------------
// Route Arguments Template
// --------------------------------------------------------------------------------
abstract class _RouteArgsTemplate {
  // properties
  Group _group;
  List<String> _axisCustom;
  void Function(List<String>) _valSetAxisCustom;

  // constructors
  _RouteArgsTemplate();

  _RouteArgsTemplate.group(
    this._group,
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

class RouteArgsReorderAxisCustom extends _RouteArgsTemplate {
  RouteArgsReorderAxisCustom({
    @required List<String> axisCustom,
    @required void Function(List<String>) valSetAxisCustom,
  }) : super.reorderAxisCustom(axisCustom, valSetAxisCustom);

  get axisCustom => this._axisCustom;
  get valSetAxisCustom => this._valSetAxisCustom;
}
