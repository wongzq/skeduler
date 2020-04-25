import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/shared/functions.dart';

class TimetableGridBox extends StatelessWidget {
  /// properties
  final BuildContext context;
  final String initialDisplay;
  final int flex;
  final bool content;

  /// constructors
  const TimetableGridBox(
    this.context,
    this.initialDisplay, {
    this.flex = 1,
    this.content = false,
    Key key,
  }) : super(key: key);

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
          color: content
              ? getOriginThemeData(group.colorShade.themeId).primaryColorLight
              : getOriginThemeData(group.colorShade.themeId).primaryColor,
        ),
        child: Text(
          member != null ? member.display : initialDisplay ?? '',
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
    ValueNotifier<bool> editMode = Provider.of<ValueNotifier<bool>>(context);

    Member member;

    return group == null
        ? Container()
        : Expanded(
            flex: flex,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return editMode.value == true
                    ? Padding(
                        padding: EdgeInsets.all(2.0),
                        child: DragTarget<Member>(
                          onAccept: (newMember) {
                            member = newMember;
                          },
                          onLeave: (prevMember) {
                            member = null;
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
