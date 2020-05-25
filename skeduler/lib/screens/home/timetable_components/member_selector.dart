import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/shared/functions.dart';

class MemberSelector extends StatelessWidget {
  final double _bodyHoriPadding = 5.0;
  final double _chipPadding = 5;
  final double _chipPaddingExtra = 2;
  final double _chipLabelHoriPadding = 5;
  final double _chipLabelVertPadding = 5;

  final bool activated;
  final double additionalSpacing;

  const MemberSelector({
    Key key,
    this.activated = true,
    this.additionalSpacing = 0,
  }) : super(key: key);

  Widget _buildMaterialActionChip(Member member, double chipWidth) {
    return Material(
      color: Colors.transparent,
      child: ActionChip(
        backgroundColor: member.colorShade != null
            ? getColorFromColorShade(member.colorShade)
            : null,
        elevation: activated ? 3.0 : 0.0,
        labelPadding: EdgeInsets.symmetric(
          horizontal: _chipLabelHoriPadding,
          vertical: _chipLabelVertPadding,
        ),
        label: Container(
          width: chipWidth,
          child: Text(
            member.display,
            textAlign: TextAlign.center,
            style: activated ? null : TextStyle(color: Colors.grey),
          ),
        ),
        onPressed: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    TimetableEditMode editMode = Provider.of<TimetableEditMode>(context);

    double _chipWidth =
        (MediaQuery.of(context).size.width - 2 * _bodyHoriPadding) / 5 -
            (2 * _chipLabelHoriPadding) -
            (2 * _chipPadding) -
            8;

    ScrollController controller = ScrollController();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        height: 70.0,
        child: ListView.builder(
          physics: BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          scrollDirection: Axis.horizontal,
          controller: controller,
          itemCount: groupStatus.members.length + 1,
          itemBuilder: (BuildContext context, int index) {
            return index == groupStatus.members.length
                ? Container(
                    height: 1,
                    width: additionalSpacing,
                  )
                : groupStatus.members[index].role == MemberRole.pending
                    ? Container()
                    : Padding(
                        padding:
                            EdgeInsets.all(_chipPadding + _chipPaddingExtra),
                        child: Center(
                          child: Wrap(
                            children: [
                              LongPressDraggable<TimetableDragData>(
                                data: TimetableDragMember(
                                  docId: groupStatus.members[index].docId,
                                  display: groupStatus.members[index].display,
                                ),
                                feedback: _buildMaterialActionChip(
                                  groupStatus.members[index],
                                  _chipWidth,
                                ),
                                child: _buildMaterialActionChip(
                                  groupStatus.members[index],
                                  _chipWidth,
                                ),
                                onDragStarted: () {
                                  editMode.isDragging = true;
                                  editMode.isDraggingData = TimetableDragMember(
                                    docId: groupStatus.members[index].docId,
                                    display: groupStatus.members[index].display,
                                  );
                                },
                                onDragCompleted: () {
                                  editMode.isDragging = false;
                                  editMode.isDraggingData = null;
                                },
                                onDraggableCanceled: (_, __) {
                                  editMode.isDragging = false;
                                  editMode.isDraggingData = null;
                                },
                              ),
                            ],
                          ),
                        ),
                      );
          },
        ),
      ),
    );
  }
}
