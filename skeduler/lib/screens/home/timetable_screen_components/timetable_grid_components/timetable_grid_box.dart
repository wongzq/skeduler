import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_switch_dialog.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:theme_provider/theme_provider.dart';

enum GridBoxType { header, content, switchBox, axisBox, placeholderBox }

class TimetableGridBox extends StatefulWidget {
  /// properties
  final GridBoxType gridBoxType;
  final String initialDisplay;
  final int flex;
  final ValueSetter<bool> valSetBinVisible;
  final bool textOverFlowFade;

  final GridAxisType gridAxisType;
  final TimetableAxes axes;
  final TimetableCoord coord;

  /// constructors
  const TimetableGridBox({
    Key key,
    @required this.gridBoxType,
    this.initialDisplay = '',
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

  TimetableStatus _ttbStatus;
  TimetableAxes _axes;
  EditModeBool _editMode;
  BinVisibleBool _binVisible;

  bool _isHovered = false;
  bool _showFootPrint = false;

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
                    color = _slotData.memberDisplay == null
                        ? Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[400]
                            : Colors.grey
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
                return _showFootPrint || _isHovered
                    ? color.withOpacity(0.5)
                    : color;
              }(),
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
                  : _slotData.memberDisplay != null
                      ? _slotData.memberDisplay
                      : widget.initialDisplay ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: widget.gridBoxType == GridBoxType.content
                      ? Colors.black
                      : getOriginThemeData(ThemeProvider.themeOf(context).id)
                          .primaryTextTheme
                          .title
                          .color,
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
        builder: (context) {
          return TimetableSwitchDialog(
            initialAxes: widget.axes,
          );
        },
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
      child: DragTarget<String>(
        onWillAccept: (_) {
          if (_editMode.value == true) {
            _isHovered = true;
            return true;
          } else {
            return false;
          }
        },
        onLeave: (_) {
          if (_editMode.value == true) {
            _isHovered = false;
          }
        },
        onAccept: (newMemberDisplay) {
          if (_editMode.value == true) {
            _isHovered = false;
            _slotData.memberDisplay = newMemberDisplay;
            _ttbStatus.perm.slotDataList.push(_slotData);
          }
        },
        builder: (context, _, __) {
          return _slotData.memberDisplay == null
              ? _buildGridBox(constraints)
              : LongPressDraggable<String>(
                  data: _slotData.memberDisplay,
                  feedback: _buildGridBox(constraints),
                  child: _buildGridBox(constraints),
                  onDragStarted: () {
                    if (_editMode.value == true) {
                      _showFootPrint = true;
                      _binVisible.value = true;
                      _ttbStatus.perm.slotDataList.pop(_slotData);
                    }
                  },
                  onDragCompleted: () {
                    if (_editMode.value == true) {
                      _showFootPrint = false;
                      _binVisible.value = false;
                    }
                  },
                  onDraggableCanceled: (_, __) {
                    if (_editMode.value == true) {
                      _showFootPrint = false;
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

    _ttbStatus = widget.gridBoxType == GridBoxType.content
        ? Provider.of<TimetableStatus>(context)
        : null;

    _slotData = TimetableSlotData();

    _slotData =
        widget.gridBoxType == GridBoxType.content && widget.coord != null
            ? () {
                TimetableSlotData returnSlotData;

                if (_editMode.value == true) {
                  _ttbStatus.perm.slotDataList.value.forEach((slotData) {
                    if (slotData.hasSameCoordAs(widget.coord)) {
                      returnSlotData = TimetableSlotData.copy(slotData);
                    }
                  });
                } else {
                  _ttbStatus.curr.slotDataList.value.forEach((slotData) {
                    if (slotData.hasSameCoordAs(widget.coord)) {
                      returnSlotData = TimetableSlotData.copy(slotData);
                    }
                  });
                }
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
