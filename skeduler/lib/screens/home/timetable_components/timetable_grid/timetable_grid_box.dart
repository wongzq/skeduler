import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/models/firestore/user.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_grid/timetable_switch_dialog.dart';

enum GridBoxType { header, content, switchBox, axisBox, placeholderBox }

class TimetableGridBox extends StatefulWidget {
  // properties
  final GridBoxType gridBoxType;
  final String initialDisplay;
  final double heightRatio;
  final double widthRatio;
  final ValueSetter<bool> valSetBinVisible;
  final bool textOverFlowFade;

  final GridAxis gridAxis;
  final TimetableAxes axes;
  final TimetableCoord coord;
  final bool editingForAxisBox;

  // constructors
  const TimetableGridBox({
    Key key,
    @required this.gridBoxType,
    @required this.heightRatio,
    @required this.widthRatio,
    this.initialDisplay = '',
    this.gridAxis,
    this.valSetBinVisible,
    this.textOverFlowFade = true,
    this.coord,
    this.axes,
    this.editingForAxisBox,
  }) : super(key: key);

  @override
  _TimetableGridBoxState createState() => _TimetableGridBoxState();
}

class _TimetableGridBoxState extends State<TimetableGridBox> {
  // properties
  OriginTheme _originTheme;

  User _user;
  GroupStatus _groupStatus;
  TimetableGridData _gridData;

  TimetableStatus _ttbStatus;
  TimetableAxes _axes;
  TimetableEditMode _editMode;

  bool _isHovered = false;
  bool _showTrace = false;

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
        padding: EdgeInsets.all(2.0),
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
                Color color;

                switch (widget.gridBoxType) {
                  case GridBoxType.header:
                    color = _originTheme.primaryColor;
                    break;

                  case GridBoxType.content:
                    color = () {
                      Color activatedColor = _originTheme.primaryColorLight;

                      Color deactivatedColor = Colors.grey.shade400;

                      return _editMode != null && _editMode.editing
                          // is editing
                          ? _editMode.isDragging
                              // something is dragging
                              // check validity
                              ? _editMode.isDraggingData.hasSubjectOnly ||
                                      (_editMode.isDraggingData.hasSubject &&
                                          _editMode.dragSubjectOnly) ||
                                      (memberIsAvailable(
                                              _editMode.isDraggingData) &&
                                          !memberIsAssigned(
                                              _editMode.isDraggingData))
                                  ? activatedColor
                                  : deactivatedColor

                              // something is not dragging
                              : _gridData.dragData == null ||
                                      _gridData.dragData.isEmpty
                                  ? deactivatedColor
                                  : _gridData.available
                                      // member is available
                                      ? _editMode.dragSubjectAndMember &&
                                              _gridData.dragData.isNotEmpty
                                          ? activatedColor
                                          : _editMode.dragSubjectOnly &&
                                                  _gridData.dragData.subject
                                                      .isNotEmpty
                                              ? activatedColor
                                              : _editMode.dragMemberOnly &&
                                                      _gridData.dragData.member
                                                          .isNotEmpty
                                                  ? activatedColor
                                                  : deactivatedColor
                                      // member is unavailable
                                      : deactivatedColor

                          // not editing
                          : _editMode.viewMe
                              // view me
                              ? () {
                                  Member member =
                                      _groupStatus.members.firstWhere(
                                    (member) => member.docId == _user.email,
                                    orElse: () => null,
                                  );

                                  return _gridData.dragData.member.docId ==
                                      member.docId;
                                }()
                                  ? activatedColor
                                  : deactivatedColor
                              // default view
                              : _gridData.dragData == null ||
                                      _gridData.dragData.isEmpty
                                  ? deactivatedColor
                                  : _gridData.available
                                      // member is available
                                      ? activatedColor
                                      // member is unavailable
                                      : deactivatedColor;
                    }();
                    break;

                  case GridBoxType.switchBox:
                    color = _originTheme.primaryColor;
                    break;

                  case GridBoxType.axisBox:
                    color = _originTheme.primaryColor;
                    break;

                  case GridBoxType.placeholderBox:
                    color = Colors.grey;
                    break;

                  default:
                    color = Colors.transparent;
                    break;
                }

                return _showTrace || _isHovered
                    ? color.withOpacity(0.5)
                    : color;
              }(),
            ),
            child: Text(
              widget.gridBoxType == GridBoxType.axisBox
                  ? () {
                      switch (widget.gridAxis) {
                        case GridAxis.x:
                          return getAxisTypeStr(_axes.xDataAxis);
                          break;
                        case GridAxis.y:
                          return getAxisTypeStr(_axes.yDataAxis);
                          break;
                        case GridAxis.z:
                          return getAxisTypeStr(_axes.zDataAxis);
                          break;
                        default:
                          return widget.initialDisplay ?? '';
                      }
                    }()
                  : widget.gridBoxType == GridBoxType.content &&
                          _gridData.dragData != null &&
                          _gridData.dragData.isNotEmpty
                      ? isFeedback
                          ? _editMode.dragSubjectAndMember
                              ? _gridData.dragData.display ??
                                  widget.initialDisplay
                              : _editMode.dragSubjectOnly
                                  ? _gridData.dragData.subject.display ??
                                      widget.initialDisplay
                                  : _editMode.dragMemberOnly
                                      ? _gridData.dragData.member.display ??
                                          widget.initialDisplay
                                      : widget.initialDisplay
                          : _gridData.dragData.display ?? widget.initialDisplay
                      : widget.initialDisplay,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.gridBoxType == GridBoxType.content
                    ? Colors.black
                    : _originTheme.textColor,
                fontSize: 10.0,
                fontStyle: FontStyle.normal,
              ),
              maxLines: widget.textOverFlowFade ? 2 : null,
              overflow: widget.textOverFlowFade ? TextOverflow.fade : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridBoxSwitch(BoxConstraints constraints) {
    return GestureDetector(
      onTap: () async => await showDialog(
        context: context,
        builder: (context) {
          return TimetableSwitchDialog(_editMode.editing);
        },
      ),
      child: _buildGridBox(constraints),
    );
  }

  Widget _buildGridBoxHeader(BoxConstraints constraints) {
    return _buildGridBox(constraints);
  }

  Widget _buildGridBoxContent(BoxConstraints constraints) {
    return DragTarget<TimetableDragData>(
      onWillAccept: (_) {
        if (_editMode.editing) {
          _isHovered = true;
          return true;
        } else {
          return false;
        }
      },
      onLeave: (_) {
        if (_editMode.editing) {
          _isHovered = false;
        }
      },
      onAccept: (newDragData) {
        if (_editMode.editing) {
          _isHovered = false;

          bool _memberIsAvailable = false;

          if (newDragData is TimetableDragMember ||
              newDragData is TimetableDragSubjectMember) {
            if (memberIsAvailable(newDragData) &&
                !memberIsAssigned(newDragData)) {
              _memberIsAvailable = true;
            }
          }

          if (newDragData is TimetableDragMember && _memberIsAvailable) {
            _gridData.dragData.member = newDragData;
          } else if (newDragData is TimetableDragSubject) {
            _gridData.dragData.subject = newDragData;
          } else if (newDragData is TimetableDragSubjectMember) {
            if (newDragData.hasSubjectOnly) {
              _gridData.dragData.subject = newDragData.subject;
            } else if (newDragData.hasMemberOnly && _memberIsAvailable) {
              _gridData.dragData.member = newDragData.member;
            } else if (newDragData.hasSubjectAndMember && _memberIsAvailable) {
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
                maxSimultaneousDrags: _editMode.dragSubjectAndMember &&
                        _gridData.dragData.isNotEmpty
                    ? 1
                    : _editMode.dragSubjectOnly &&
                            _gridData.dragData.subject.isNotEmpty
                        ? 1
                        : _editMode.dragMemberOnly &&
                                _gridData.dragData.member.isNotEmpty
                            ? 1
                            : 0,
                data: _editMode.dragSubjectAndMember
                    ? _gridData.dragData
                    : _editMode.dragSubjectOnly
                        ? TimetableDragSubject(
                            docId: _gridData.dragData.subject.docId,
                            display: _gridData.dragData.subject.display,
                          )
                        : _editMode.dragMemberOnly
                            ? TimetableDragMember(
                                docId: _gridData.dragData.member.docId,
                                display: _gridData.dragData.member.display,
                              )
                            : null,
                feedback: _buildGridBox(constraints, isFeedback: true),
                child: _buildGridBox(constraints),
                onDragStarted: () {
                  if (_editMode.editing) {
                    _showTrace = true;
                    _editMode.binVisible = true;
                    _editMode.isDragging = true;
                    _editMode.isDraggingData = _gridData.dragData;

                    if (_gridData.dragData.hasSubjectAndMember) {
                      if (_editMode.dragSubjectAndMember) {
                        _ttbStatus.edit.gridDataList.pop(_gridData);
                      } else if (_editMode.dragSubjectOnly) {
                        _ttbStatus.edit.gridDataList.push(
                          TimetableGridData(
                            coord: _gridData.coord,
                            dragData: TimetableDragSubjectMember(
                              member: _gridData.dragData.member,
                            ),
                            available: true,
                          ),
                        );
                      } else if (_editMode.dragMemberOnly) {
                        _ttbStatus.edit.gridDataList.push(
                          TimetableGridData(
                            coord: _gridData.coord,
                            dragData: TimetableDragSubjectMember(
                              subject: _gridData.dragData.subject,
                            ),
                            available: true,
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
                  if (_editMode.editing) {
                    _showTrace = false;
                    _editMode.binVisible = false;
                    _editMode.isDragging = false;
                    _editMode.isDraggingData = null;
                  }
                },
                onDraggableCanceled: (_, __) {
                  if (_editMode.editing) {
                    _showTrace = false;
                    _editMode.binVisible = false;
                    _editMode.isDragging = false;
                    _editMode.isDraggingData = null;
                  }
                },
              );
      },
    );
  }

  Widget _buildGridBoxAxisBox(BoxConstraints constraints) {
    BoxConstraints feedbackConstraints = BoxConstraints(
      maxWidth: 50.0,
      maxHeight: 50.0,
    );

    return DragTarget<GridAxis>(
      onWillAccept: (_) {
        _isHovered = true;
        return true;
      },
      onLeave: (_) {
        _isHovered = false;
      },
      onAccept: (newGridAxis) {
        _isHovered = false;
        if (widget.editingForAxisBox) {
          if (_ttbStatus.editAxes.dayGridAxis == widget.gridAxis) {
            _ttbStatus.editDayGridAxis = newGridAxis;
          } else if (_ttbStatus.editAxes.timeGridAxis == widget.gridAxis) {
            _ttbStatus.editTimeGridAxis = newGridAxis;
          } else if (_ttbStatus.editAxes.customGridAxis == widget.gridAxis) {
            _ttbStatus.editCustomGridAxis = newGridAxis;
          }
        } else {
          if (_ttbStatus.currAxes.dayGridAxis == widget.gridAxis) {
            _ttbStatus.currDayGridAxis = newGridAxis;
            _ttbStatus.currAxesIsCustom = true;
          } else if (_ttbStatus.currAxes.timeGridAxis == widget.gridAxis) {
            _ttbStatus.currTimeGridAxis = newGridAxis;
            _ttbStatus.currAxesIsCustom = true;
          } else if (_ttbStatus.currAxes.customGridAxis == widget.gridAxis) {
            _ttbStatus.currCustomGridAxis = newGridAxis;
            _ttbStatus.currAxesIsCustom = true;
          }
        }
      },
      builder: (context, _, __) {
        return LongPressDraggable<GridAxis>(
          data: widget.gridAxis,
          feedback: _buildGridBox(
            constraints,
            shrinkConstraints: feedbackConstraints,
          ),
          child: _buildGridBox(constraints),
        );
      },
    );
  }

  Widget _buildGridBoxPlaceholderBox(BoxConstraints constraints) {
    return _buildGridBox(constraints);
  }

  bool memberIsAvailable(TimetableDragData dragData) {
    Member memberFound;

    bool isAvailable = false;

    if (dragData is TimetableDragMember) {
      _groupStatus.members.forEach((member) {
        if (member.docId == dragData.docId) {
          memberFound = member;
        }
      });
    } else if (dragData is TimetableDragSubject) {
      isAvailable = true;
    } else if (dragData is TimetableDragSubjectMember) {
      _groupStatus.members.forEach((member) {
        if (member.docId == dragData.member.docId) {
          memberFound = member;
        }
      });
    }

    if (memberFound != null) {
      if (memberFound.role == MemberRole.dummy) {
        isAvailable = true;
      } else {
        // for each day within timetable range
        isAvailable = true;

        timetableRangeLoop:
        for (int i = 0;
            i <
                _ttbStatus.edit.endDate
                    .add(Duration(days: 1))
                    .difference(_ttbStatus.edit.startDate)
                    .inDays;
            i++) {
          DateTime ttbDate = _ttbStatus.edit.startDate.add(Duration(days: i));

          Time gridTime = Time(
            startTime: DateTime(
              ttbDate.year,
              ttbDate.month,
              ttbDate.day,
              _gridData.coord.time.startTime.hour,
              _gridData.coord.time.startTime.minute,
            ),
            endTime: DateTime(
              ttbDate.year,
              ttbDate.month,
              ttbDate.day,
              _gridData.coord.time.endTime.hour,
              _gridData.coord.time.endTime.minute,
            ),
          );

          bool availableTimeFound = false;

          if (Weekday.values[ttbDate.weekday - 1] == _gridData.coord.day) {
            if (memberFound.alwaysAvailable) {
              for (Time time in memberFound.timesUnavailable) {
                if (!gridTime.notWithinDateTimeOf(time)) {
                  isAvailable = false;
                  break timetableRangeLoop;
                }
              }
            } else if (!memberFound.alwaysAvailable) {
              memberTimesLoop:
              for (Time time in memberFound.timesAvailable) {
                if (gridTime.withinDateTimeOf(time)) {
                  availableTimeFound = true;
                  break memberTimesLoop;
                }
              }

              if (!memberFound.alwaysAvailable && !availableTimeFound) {
                isAvailable = false;
                break timetableRangeLoop;
              }
            }
          }
        }
      }
    }

    return isAvailable;
  }

  bool memberIsAssigned(
    TimetableDragData checkDragData,
  ) {
    bool isAssigned;
    String memberDocId;

    if (checkDragData is TimetableDragMember) {
      memberDocId = checkDragData.docId;
    } else if (checkDragData is TimetableDragSubjectMember) {
      memberDocId = checkDragData.member.docId;
    }

    if (memberDocId != null) {
      isAssigned = _ttbStatus.edit.gridDataList.value.firstWhere((gridData) {
                return gridData.dragData.member.docId == memberDocId &&
                    gridData.coord.day == _gridData.coord.day &&
                    gridData.coord.time == _gridData.coord.time;
              }, orElse: () => null) !=
              null
          ? true
          : false;
    } else {
      isAssigned = false;
    }

    return isAssigned;
  }

  @override
  Widget build(BuildContext context) {
    _originTheme = Provider.of<OriginTheme>(context);

    _user = widget.gridBoxType == GridBoxType.content
        ? Provider.of<User>(context)
        : null;

    _groupStatus = Provider.of<GroupStatus>(context);

    _editMode = widget.gridBoxType == GridBoxType.content ||
            widget.gridBoxType == GridBoxType.switchBox ||
            widget.gridBoxType == GridBoxType.header
        ? Provider.of<TimetableEditMode>(context)
        : null;

    _ttbStatus = widget.gridBoxType == GridBoxType.content ||
            widget.gridBoxType == GridBoxType.axisBox
        ? Provider.of<TimetableStatus>(context)
        : null;

    _axes = widget.gridBoxType == GridBoxType.axisBox
        ? widget.editingForAxisBox ? _ttbStatus.editAxes : _ttbStatus.currAxes
        : null;

    _gridData = TimetableGridData();

    _gridData =
        widget.gridBoxType == GridBoxType.content && widget.coord != null
            ? () {
                TimetableGridData returnGridData;

                if (_editMode.editing) {
                  _ttbStatus.edit.gridDataList.value.forEach((gridData) {
                    if (gridData.coord == widget.coord) {
                      returnGridData = TimetableGridData.from(gridData);
                    }
                  });
                } else {
                  _ttbStatus.curr.gridDataList.value.forEach((gridData) {
                    if (gridData.coord == widget.coord) {
                      returnGridData = TimetableGridData.from(gridData);
                    }
                  });
                }
                return returnGridData ??
                    TimetableGridData(
                      coord: widget.coord,
                      available: true,
                    );
              }()
            : TimetableGridData();

    double gridBoxSize = (MediaQuery.of(context).size.width - 20) / 6;

    return Container(
      height: widget.heightRatio * gridBoxSize,
      width: widget.widthRatio * gridBoxSize,
      child: LayoutBuilder(
        builder: (context, constraints) {
          switch (widget.gridBoxType) {
            case GridBoxType.header:
              return _buildGridBoxHeader(constraints);
              break;
            case GridBoxType.content:
              return _editMode.editing
                  ? _buildGridBoxContent(constraints)
                  : _buildGridBox(constraints);

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
