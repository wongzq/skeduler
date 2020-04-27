import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_switch_dialog.dart';
import 'package:skeduler/shared/functions.dart';

enum GridBoxType { header, content, switchBox, axisBox, placeholderBox }

class TimetableGridBox extends StatefulWidget {
  /// properties
  final BuildContext context;
  final String initialDisplay;
  final GridBoxType type;
  final int flex;
  final ValueSetter<bool> valSetBinVisible;
  final bool textOverFlowFade;

  final Weekday axisDayVal;
  final Time axisTimeVal;
  final String axisCustomVal;

  final GridAxisType gridAxisType;
  final TimetableAxes axes;

  /// constructors
  const TimetableGridBox({
    Key key,
    @required this.context,
    @required this.initialDisplay,
    @required this.type,
    this.flex = 1,
    this.valSetBinVisible,
    this.textOverFlowFade = true,
    this.axisDayVal,
    this.axisTimeVal,
    this.axisCustomVal,
    this.gridAxisType,
    this.axes,
  }) : super(key: key);

  @override
  _TimetableGridBoxState createState() => _TimetableGridBoxState();
}

class _TimetableGridBoxState extends State<TimetableGridBox> {
  /// properties

  ValueNotifier<Group> _group;
  TimetableAxes _axes;
  TimetableSlotDataList _slotDataList;
  EditModeBool _editMode;
  BinVisibleBool _binVisible;

  Member _member;

  /// methods
  Widget _buildGridBox(BoxConstraints constraints) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        alignment: Alignment.center,
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: () {
            switch (widget.type) {
              case GridBoxType.header:
                return getOriginThemeData(_group.value.colorShade.themeId)
                    .primaryColor;
                break;
              case GridBoxType.content:
                return getOriginThemeData(_group.value.colorShade.themeId)
                    .primaryColorLight;
                break;
              case GridBoxType.switchBox:
                return getOriginThemeData(_group.value.colorShade.themeId)
                    .primaryColor;
                break;
              case GridBoxType.axisBox:
                return getOriginThemeData(_group.value.colorShade.themeId)
                    .primaryColor;
                break;
              case GridBoxType.placeholderBox:
                return Colors.grey;
                break;
              default:
                return Colors.transparent;
                break;
            }
          }(),
          boxShadow: [BoxShadow(offset: Offset(0.0, 0.5), blurRadius: 0.1)],
        ),
        child: Text(
          widget.type == GridBoxType.axisBox
              ? () {
                  switch (widget.gridAxisType) {
                    case GridAxisType.x:
                      return getAxisTypeStr(_axes.xType);
                      break;
                    case GridAxisType.y:
                      return getAxisTypeStr(_axes.yType);
                      break;
                    case GridAxisType.z:
                      return getAxisTypeStr(_axes.zType);
                      break;
                    default:
                      return widget.initialDisplay ?? '';
                  }
                }()
              : _member != null ? _member.display : widget.initialDisplay ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontSize: 10.0),
          maxLines: widget.textOverFlowFade ? 1 : null,
          overflow: widget.textOverFlowFade ? TextOverflow.fade : null,
        ),
      ),
    );
  }

  Widget _buildGridBoxSwitch(Group group, BoxConstraints constraints) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        child: TimetableSwitchDialog(
          initialAxes: widget.axes,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(2.0),
        child: _buildGridBox(constraints),
      ),
    );
  }

  Widget _buildGridBoxHeader(Group group, BoxConstraints constraints) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: _buildGridBox(constraints),
    );
  }

  Widget _buildGridBoxContent(Group group, BoxConstraints constraints) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: DragTarget<Member>(
        onAccept: (newMember) {
          _member = newMember;
          _slotDataList.add(TimetableSlotData());
        },
        builder: (context, _, __) {
          return _member == null
              ? _buildGridBox(constraints)
              : LongPressDraggable<Member>(
                  data: _member,
                  feedback: _buildGridBox(constraints),
                  child: _buildGridBox(constraints),
                  onDragStarted: () {
                    _member = null;

                    if (_editMode.value == true) {
                      _binVisible.value = true;
                    }
                  },
                  onDragCompleted: () {
                    if (_editMode.value == true) {
                      _binVisible.value = false;
                    }
                  },
                  onDraggableCanceled: (_, __) {
                    if (_editMode.value == true) {
                      _binVisible.value = false;
                    }
                  },
                );
        },
      ),
    );
  }

  Widget _buildGridBoxAxisBox(Group group, BoxConstraints constraints) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: DragTarget<TimetableAxisType>(
        onAccept: (newAxisType) {
          if (widget.gridAxisType == GridAxisType.x) {
            _axes.xType = newAxisType;
          } else if (widget.gridAxisType == GridAxisType.y) {
            _axes.yType = newAxisType;
          } else if (widget.gridAxisType == GridAxisType.z) {
            _axes.zType = newAxisType;
          }
        },
        builder: (context, _, __) {
          return LongPressDraggable<TimetableAxisType>(
            data: () {
              switch (widget.gridAxisType) {
                case GridAxisType.x:
                  return _axes.xType;
                  break;
                case GridAxisType.y:
                  return _axes.yType;
                  break;
                case GridAxisType.z:
                  return _axes.zType;
                  break;
                default:
                  return null;
                  break;
              }
            }(),
            feedback: _buildGridBox(constraints),
            child: _buildGridBox(constraints),
          );
        },
      ),
    );
  }

  Widget _buildGridBoxPlaceholderBox(Group group, BoxConstraints constraints) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: _buildGridBox(constraints),
    );
  }

  @override
  Widget build(BuildContext context) {
    _group = Provider.of<ValueNotifier<Group>>(context);

    _axes = widget.type == GridBoxType.axisBox
        ? Provider.of<TimetableAxes>(context)
        : null;

    _slotDataList = widget.type == GridBoxType.content
        ? Provider.of<TimetableSlotDataList>(context)
        : null;

    _editMode = widget.type == GridBoxType.content
        ? Provider.of<EditModeBool>(context)
        : null;

    if (_editMode != null && _editMode.value == true) {
      _binVisible = Provider.of<BinVisibleBool>(context);
    }

    return _group == null
        ? Container()
        : Expanded(
            flex: widget.flex,
            child: LayoutBuilder(
              builder: (context, constraints) {
                switch (widget.type) {
                  case GridBoxType.header:
                    return _buildGridBoxHeader(_group.value, constraints);
                    break;
                  case GridBoxType.content:
                    return _editMode.value == true
                        ? _buildGridBoxContent(_group.value, constraints)
                        : Padding(
                            padding: EdgeInsets.all(2.0),
                            child: _buildGridBox(constraints),
                          );
                    break;
                  case GridBoxType.switchBox:
                    return _buildGridBoxSwitch(_group.value, constraints);
                    break;
                  case GridBoxType.axisBox:
                    return _buildGridBoxAxisBox(_group.value, constraints);
                    break;
                  case GridBoxType.placeholderBox:
                    return _buildGridBoxPlaceholderBox(
                        _group.value, constraints);
                    break;
                  default:
                    return Container();
                    break;
                }
              },
            ),
          );
  }
}
