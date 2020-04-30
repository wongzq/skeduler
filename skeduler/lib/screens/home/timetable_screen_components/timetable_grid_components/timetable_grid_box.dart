import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_switch_dialog.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:theme_provider/theme_provider.dart';

enum GridBoxType { header, content, switchBox, axisBox, placeholderBox }

class TimetableGridBox extends StatefulWidget {
  // properties
  final GridBoxType gridBoxType;
  final String initialDisplay;
  final int flex;
  final ValueSetter<bool> valSetBinVisible;
  final bool textOverFlowFade;

  final GridAxisType gridAxisType;
  final TimetableAxes axes;
  final TimetableCoord coord;

  // constructors
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
  // properties
  TimetableGridData _gridData;

  TimetableStatus _ttbStatus;
  TimetableAxes _axes;
  TimetableEditMode _editMode;
  TimetableEditorBinVisible _binVisible;

  bool _isHovered = false;
  bool _showFootPrint = false;

  // methods
  Widget _buildGridBox(
    BoxConstraints constraints, {
    BoxConstraints shrinkConstraints,
    bool isFeedback = false,
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
                    color = () {
                      Color activatedColor =
                          getOriginThemeData(themeId).primaryColorLight;

                      Color deactivatedColor =
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.grey[400]
                              : Colors.grey;

                      return _gridData.dragData == null ||
                              _gridData.dragData.isEmpty
                          ? deactivatedColor
                          : _editMode.dragSubject &&
                                  _editMode.dragMember &&
                                  _gridData.dragData.isNotEmpty
                              ? activatedColor
                              : _editMode.dragSubject &&
                                      _gridData.dragData.subject.isNotEmpty
                                  ? activatedColor
                                  : _editMode.dragMember &&
                                          _gridData.dragData.member.isNotEmpty
                                      ? activatedColor
                                      : deactivatedColor;
                    }();
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
                          return widget.initialDisplay;
                      }
                    }()
                  : widget.gridBoxType == GridBoxType.content &&
                          _gridData.dragData != null &&
                          _gridData.dragData.isNotEmpty
                      ? isFeedback
                          ? _editMode.dragSubject && _editMode.dragMember
                              ? _gridData.dragData.display ??
                                  widget.initialDisplay
                              : _editMode.dragSubject
                                  ? _gridData.dragData.subject.display ??
                                      widget.initialDisplay
                                  : _editMode.dragMember
                                      ? _gridData.dragData.member.display ??
                                          widget.initialDisplay
                                      : widget.initialDisplay
                          : _gridData.dragData.display ?? widget.initialDisplay
                      : widget.initialDisplay,
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
          return TimetableSwitchDialog();
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
      child: DragTarget<TimetableDragData>(
        onWillAccept: (_) {
          if (_editMode.editMode == true) {
            _isHovered = true;
            return true;
          } else {
            return false;
          }
        },
        onLeave: (_) {
          if (_editMode.editMode == true) {
            _isHovered = false;
          }
        },
        onAccept: (newDragData) {
          if (_editMode.editMode == true) {
            _isHovered = false;

            if (newDragData is TimetableDragMember) {
              _gridData.dragData.member.display = newDragData.display;
            } else if (newDragData is TimetableDragSubject) {
              _gridData.dragData.subject.display = newDragData.display;
            } else if (newDragData is TimetableDragSubjectMember) {
              if (newDragData.hasSubjectOnly) {
                _gridData.dragData.subject.display =
                    newDragData.subject.display;
              } else if (newDragData.hasMemberOnly) {
                _gridData.dragData.member.display = newDragData.member.display;
              } else if (newDragData.hasSubjectAndMember) {
                _gridData.dragData = newDragData;
              }
            }

            _ttbStatus.edit.gridDataList.push(_gridData);
          }
        },
        builder: (context, _, __) {
          return _gridData.dragData == null || _gridData.dragData.isEmpty
              ? _buildGridBox(constraints)
              : LongPressDraggable<TimetableDragData>(
                  maxSimultaneousDrags: _editMode.dragSubject &&
                          _editMode.dragMember &&
                          _gridData.dragData.isNotEmpty
                      ? 1
                      : _editMode.dragSubject &&
                              !_editMode.dragMember &&
                              _gridData.dragData.subject.isNotEmpty
                          ? 1
                          : !_editMode.dragSubject &&
                                  _editMode.dragMember &&
                                  _gridData.dragData.member.isNotEmpty
                              ? 1
                              : 0,
                  data: _editMode.dragSubject && _editMode.dragMember
                      ? _gridData.dragData
                      : _editMode.dragSubject
                          ? TimetableDragSubject(
                              display: _gridData.dragData.subject.display,
                            )
                          : _editMode.dragMember
                              ? TimetableDragMember(
                                  display: _gridData.dragData.member.display,
                                )
                              : null,
                  feedback: _buildGridBox(constraints, isFeedback: true),
                  child: _buildGridBox(constraints),
                  onDragStarted: () {
                    if (_editMode.editMode == true) {
                      _showFootPrint = true;
                      _binVisible.visible = true;

                      if (_gridData.dragData.hasSubjectAndMember) {
                        if (_editMode.dragSubject && _editMode.dragMember) {
                          _ttbStatus.edit.gridDataList.pop(_gridData);
                        } else if (_editMode.dragSubject &&
                            !_editMode.dragMember) {
                          _ttbStatus.edit.gridDataList.push(
                            TimetableGridData(
                              coord: _gridData.coord,
                              dragData: TimetableDragSubjectMember(
                                member: _gridData.dragData.member,
                              ),
                            ),
                          );
                        } else if (!_editMode.dragSubject &&
                            _editMode.dragMember) {
                          _ttbStatus.edit.gridDataList.push(
                            TimetableGridData(
                              coord: _gridData.coord,
                              dragData: TimetableDragSubjectMember(
                                subject: _gridData.dragData.subject,
                              ),
                            ),
                          );
                        }
                      } else if (_gridData.dragData.hasSubjectOnly) {
                        if (_editMode.dragSubject) {
                          _ttbStatus.edit.gridDataList.pop(_gridData);
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Dragging subject is disabled');
                        }
                      } else if (_gridData.dragData.hasMemberOnly) {
                        if (_editMode.dragMember) {
                          _ttbStatus.edit.gridDataList.pop(_gridData);
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Dragging member is disabled');
                        }
                      }
                    }
                  },
                  onDragCompleted: () {
                    if (_editMode.editMode == true) {
                      _showFootPrint = false;
                      _binVisible.visible = false;
                    }
                  },
                  onDraggableCanceled: (_, __) {
                    if (_editMode.editMode == true) {
                      _showFootPrint = false;
                      _binVisible.visible = false;
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
        ? Provider.of<TimetableEditMode>(context)
        : null;

    _ttbStatus = widget.gridBoxType == GridBoxType.content
        ? Provider.of<TimetableStatus>(context)
        : null;

    _gridData = TimetableGridData();

    _gridData =
        widget.gridBoxType == GridBoxType.content && widget.coord != null
            ? () {
                TimetableGridData returnGridData;

                if (_editMode.editMode == true) {
                  _ttbStatus.edit.gridDataList.value.forEach((gridData) {
                    if (gridData.hasSameCoordAs(widget.coord)) {
                      returnGridData = TimetableGridData.copy(gridData);
                    }
                  });
                } else {
                  _ttbStatus.curr.gridDataList.value.forEach((gridData) {
                    if (gridData.hasSameCoordAs(widget.coord)) {
                      returnGridData = TimetableGridData.copy(gridData);
                    }
                  });
                }
                return returnGridData ?? TimetableGridData(coord: widget.coord);
              }()
            : TimetableGridData();

    if (_editMode != null && _editMode.editMode == true) {
      _binVisible = Provider.of<TimetableEditorBinVisible>(context);
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
              return _editMode.editMode == true
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
