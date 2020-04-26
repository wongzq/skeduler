import 'package:flutter/material.dart';
import 'package:skeduler/models/group_data/group.dart';

////////////////////////////////////////////////////////////////////////////////
/// Route Arguments Template
////////////////////////////////////////////////////////////////////////////////
abstract class _RouteArgsTemplate {
  /// properties
  BuildContext _context;
  Group _group;
  List<String> _axisCustom;
  void Function(List<String>) _valSetAxisCustom;

  /// constructors
  _RouteArgsTemplate(
    this._context,
  );

  _RouteArgsTemplate.group(
    this._context,
    this._group,
  );

  _RouteArgsTemplate.reorderAxisCustom(
    this._context,
    this._axisCustom,
    this._valSetAxisCustom,
  );
}

////////////////////////////////////////////////////////////////////////////////
/// Route Arguments related classes
////////////////////////////////////////////////////////////////////////////////
class RouteArgs extends _RouteArgsTemplate {
  RouteArgs(BuildContext context) : super(context);

  get context => super._context;
}

class RouteArgsGroup extends _RouteArgsTemplate {
  RouteArgsGroup(BuildContext context, {@required Group group})
      : super.group(context, group);

  get context => super._context;
  get group => this._group;
}

class RouteArgsReorderAxisCustom extends _RouteArgsTemplate {
  RouteArgsReorderAxisCustom(
    BuildContext context, {
    @required List<String> axisCustom,
    @required void Function(List<String>) valSetAxisCustom,
  }) : super.reorderAxisCustom(context, axisCustom, valSetAxisCustom);

  get context => super._context;
  get axisCustom => this._axisCustom;
  get valSetAxisCustom => this._valSetAxisCustom;
}
