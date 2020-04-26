import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/shared/functions.dart';

class TimetableGridBox extends StatefulWidget {
  /// properties
  final BuildContext context;
  final String initialDisplay;
  final int flex;
  final bool content;
  final ValueSetter<bool> valSetBinVisible;

  /// constructors
  const TimetableGridBox({
    Key key,
    @required this.context,
    @required this.initialDisplay,
    this.flex = 1,
    this.content = false,
    this.valSetBinVisible,
  }) : super(key: key);

  @override
  _TimetableGridBoxState createState() => _TimetableGridBoxState();
}

class _TimetableGridBoxState extends State<TimetableGridBox> {
  /// properties
  Member member;

  /// methods
  Widget _buildGridBox(Group group, Member member, BoxConstraints constraints) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        alignment: Alignment.center,
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: widget.content
              ? getOriginThemeData(group.colorShade.themeId).primaryColorLight
              : getOriginThemeData(group.colorShade.themeId).primaryColor,
        ),
        child: Text(
          member != null ? member.display : widget.initialDisplay ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontSize: 10.0),
          maxLines: 1,
          overflow: TextOverflow.fade,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Group> group = Provider.of<ValueNotifier<Group>>(context);
    EditModeBool editMode = Provider.of<EditModeBool>(context);
    BinVisibleBool binVisible;

    if (editMode.value == true)
      binVisible = Provider.of<BinVisibleBool>(context);

    return group == null
        ? Container()
        : Expanded(
            flex: widget.flex,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return editMode.value == true
                    ? Padding(
                        padding: EdgeInsets.all(2.0),
                        child: DragTarget<Member>(
                          onAccept: (newMember) {
                            member = newMember;
                          },
                          builder: (context, _, __) {
                            return member == null
                                ? _buildGridBox(
                                    group.value, member, constraints)
                                : LongPressDraggable<Member>(
                                    data: member,
                                    feedback: _buildGridBox(
                                        group.value, member, constraints),
                                    child: _buildGridBox(
                                        group.value, member, constraints),
                                    onDragStarted: () {
                                      member = null;

                                      if (editMode.value == true) {
                                        binVisible.value = true;
                                      }
                                    },
                                    onDragCompleted: () {
                                      if (editMode.value == true) {
                                        binVisible.value = false;
                                      }
                                    },
                                    onDraggableCanceled: (_, __) {
                                      if (editMode.value == true) {
                                        binVisible.value = false;
                                      }
                                    },
                                  );
                          },
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(2.0),
                        child: _buildGridBox(group.value, member, constraints),
                      );
              },
            ),
          );
  }
}
