import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/subject.dart';
import 'package:skeduler/shared/functions.dart';

class SubjectSelector extends StatelessWidget {
  final double _bodyHoriPadding = 5.0;
  final double _chipPadding = 5;
  final double _chipPaddingExtra = 2;
  final double _chipLabelHoriPadding = 5;
  final double _chipLabelVertPadding = 5;

  final bool activated;
  final double additionalSpacing;

  const SubjectSelector({
    Key key,
    this.activated,
    this.additionalSpacing,
  }) : super(key: key);

  Widget _buildMaterialActionChip(Subject subject, double chipWidth) {
    return Material(
      color: Colors.transparent,
      child: ActionChip(
        backgroundColor: subject.colorShade != null
            ? getColorFromColorShade(subject.colorShade)
            : null,
        elevation: activated ? 3.0 : 0.0,
        labelPadding: EdgeInsets.symmetric(
          horizontal: _chipLabelHoriPadding,
          vertical: _chipLabelVertPadding,
        ),
        label: Container(
          width: chipWidth,
          child: Text(
            subject.display,
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
          itemCount: groupStatus.group.subjects.length + 1,
          itemBuilder: (BuildContext context, int index) {
            return index == groupStatus.group.subjects.length
                ? Container(
                    height: 1,
                    width: additionalSpacing,
                  )
                : Padding(
                    padding: EdgeInsets.all(_chipPadding + _chipPaddingExtra),
                    child: Wrap(
                      children: [
                        LongPressDraggable<TimetableDragData>(
                          data: TimetableDragSubject(
                            display: groupStatus.group.subjects[index].display,
                          ),
                          feedback: _buildMaterialActionChip(
                            groupStatus.group.subjects[index],
                            _chipWidth,
                          ),
                          child: _buildMaterialActionChip(
                            groupStatus.group.subjects[index],
                            _chipWidth,
                          ),
                          onDragStarted: () {
                            editMode.isDragging = true;
                            editMode.isDraggingData = TimetableDragSubject(
                              display:
                                  groupStatus.group.subjects[index].display,
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
                  );
          },
        ),
      ),
    );
  }
}
