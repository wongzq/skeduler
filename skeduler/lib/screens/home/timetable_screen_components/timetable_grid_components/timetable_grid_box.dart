import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_switch_dialog.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:theme_provider/theme_provider.dart';

enum GridBoxType { header, content, switchBox, axisBox, placeholderBox }

class TimetableGridBox extends StatefulWidget {
  /// properties
  final BuildContext context;
  final String initialDisplay;
  final GridBoxType gridBoxType;
  final int flex;
  final ValueSetter<bool> valSetBinVisible;
  final bool textOverFlowFade;

  final GridAxisType gridAxisType;
  final TimetableAxes axes;
  final TimetableCoord coord;

  /// constructors
  const TimetableGridBox({
    Key key,
    @required this.context,
    @required this.initialDisplay,
    @required this.gridBoxType,
    this.gridAxisType,
    this.flex = 1,
    this.valSetBinVisible,
    this.textOverFlowFade = true,
    this.coord,
    this.axes,
  }) : super(key: key);

  @override
  _TimetableGridBoxState createState() => _TimetableGridBoxState();
}

class _TimetableGridBoxState extends State<TimetableGridBox> {
  /// properties
  TimetableSlotData _slotData;

  TimetableSlotDataList _slotDataList;
  TimetableAxes _axes;
  EditModeBool _editMode;
  BinVisibleBool _binVisible;

  // Member _member;

  bool _isHovered = false;

  /// methods
  Widget _buildGridBox(
    BoxConstraints constraints, {
    BoxConstraints shrinkConstraints,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        child: Center(
          child: Container(
            height: shrinkConstraints != null
                ? shrinkConstraints.maxHeight
                : constraints.maxHeight,
            width: shrinkConstraints != null
                ? shrinkConstraints.maxWidth
                : constraints.maxWidth,
            alignment: Alignment.center,
            padding: EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: () {
                String themeId = ThemeProvider.themeOf(context).id;
                Color color;
                switch (widget.gridBoxType) {
                  case GridBoxType.header:
                    color = getOriginThemeData(themeId).primaryColor;
                    break;
                  case GridBoxType.content:
                    color = _slotData.member == null
                        ? Colors.grey
                        : getOriginThemeData(themeId).primaryColorLight;
                    break;
                  case GridBoxType.switchBox:
                    color = getOriginThemeData(themeId).primaryColor;
                    break;
                  case GridBoxType.axisBox:
                    color = getOriginThemeData(themeId).primaryColor;
                    break;
                  case GridBoxType.placeholderBox:
                    color = Colors.grey;
                    break;
                  default:
                    color = Colors.transparent;
                    break;
                }
                return _isHovered ? color.withOpacity(0.5) : color;
              }(),
              boxShadow: [BoxShadow(offset: Offset(0.0, 0.5), blurRadius: 0.1)],
            ),
            child: Text(
              widget.gridBoxType == GridBoxType.axisBox
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
                  : _slotData.member != null
                      ? _slotData.member.display
                      : widget.initialDisplay ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: widget.gridBoxType == GridBoxType.header ||
                          widget.gridBoxType == GridBoxType.switchBox
                      ? getOriginThemeData(ThemeProvider.themeOf(context).id)
                          .primaryTextTheme
                          .title
                          .color
                      : Colors.black,
                  fontSize: 10.0),
              maxLines: widget.textOverFlowFade ? 1 : null,
              overflow: widget.textOverFlowFade ? TextOverflow.fade : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridBoxSwitch(BoxConstraints constraints) {
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

  Widget _buildGridBoxHeader(BoxConstraints constraints) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: _buildGridBox(constraints),
    );
  }

  Widget _buildGridBoxContent(BoxConstraints constraints) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: DragTarget<Member>(
        onWillAccept: (_) {
          _isHovered = true;
          return true;
        },
        onLeave: (_) {
          _isHovered = false;
        },
        onAccept: (newMember) {
          _isHovered = false;
          _slotData.member = newMember;
          _slotDataList.push(_slotData);
          
          _slotDataList.printAll();
        },
        builder: (context, _, __) {
          return _slotData.member == null
              ? _buildGridBox(constraints)
              : LongPressDraggable<Member>(
                  data: _slotData.member,
                  feedback: _buildGridBox(constraints),
                  child: _buildGridBox(constraints),
                  onDragStarted: () {
                    _slotData.member = null;
                    _slotDataList.pop(_slotData);

                    _slotDataList.printAll();

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

  Widget _buildGridBoxAxisBox(BoxConstraints constraints) {
    BoxConstraints feedbackConstraints = BoxConstraints(
      maxWidth: 50.0,
      maxHeight: 50.0,
    );

    return Padding(
      padding: EdgeInsets.all(2.0),
      child: DragTarget<TimetableAxisType>(
        onWillAccept: (_) {
          _isHovered = true;
          return true;
        },
        onLeave: (_) {
          _isHovered = false;
        },
        onAccept: (newAxisType) {
          _isHovered = false;
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
            feedback: _buildGridBox(
              constraints,
              shrinkConstraints: feedbackConstraints,
            ),
            child: _buildGridBox(constraints),
          );
        },
      ),
    );
  }

  Widget _buildGridBoxPlaceholderBox(BoxConstraints constraints) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: _buildGridBox(constraints),
    );
  }

  @override
  Widget build(BuildContext context) {
    _axes = widget.gridBoxType == GridBoxType.axisBox
        ? Provider.of<TimetableAxes>(context)
        : null;

    _editMode = widget.gridBoxType == GridBoxType.content
        ? Provider.of<EditModeBool>(context)
        : null;

    _slotDataList = widget.gridBoxType == GridBoxType.content
        ? Provider.of<TimetableSlotDataList>(context)
        : null;

    _slotData = TimetableSlotData();

    _slotData =
        widget.gridBoxType == GridBoxType.content && widget.coord != null
            ? () {
                TimetableSlotData returnSlotData;

                _slotDataList.value.forEach((slotData) {
                  if (slotData.hasSameCoordAs(widget.coord)) {
                    returnSlotData = TimetableSlotData.copy(slotData);
                  }
                });
                return returnSlotData ?? TimetableSlotData(coord: widget.coord);
              }()
            : TimetableSlotData();

    if (_editMode != null && _editMode.value == true) {
      _binVisible = Provider.of<BinVisibleBool>(context);
    }

    return Expanded(
      flex: widget.flex,
      child: LayoutBuilder(
        builder: (context, constraints) {
          switch (widget.gridBoxType) {
            case GridBoxType.header:
              return _buildGridBoxHeader(constraints);
              break;
            case GridBoxType.content:
              return _editMode.value == true
                  ? _buildGridBoxContent(constraints)
                  : Padding(
                      padding: EdgeInsets.all(2.0),
                      child: _buildGridBox(constraints),
                    );
              break;
            case GridBoxType.switchBox:
              return _buildGridBoxSwitch(constraints);
              break;
            case GridBoxType.axisBox:
              return _buildGridBoxAxisBox(constraints);
              break;
            case GridBoxType.placeholderBox:
              return _buildGridBoxPlaceholderBox(constraints);
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
