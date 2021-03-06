import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/screens/home/timetable_components/timetable_grid/timetable_grid_box.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimetableSwitchDialog extends StatefulWidget {
  final bool editing;

  const TimetableSwitchDialog(this.editing, {Key key}) : super(key: key);

  @override
  _TimetableSwitchDialogState createState() => _TimetableSwitchDialogState();
}

class _TimetableSwitchDialogState extends State<TimetableSwitchDialog> {
  TimetableAxes _axes;

  Widget _generateSwitchContainer(BuildContext context) {
    double totalWidthRatio = 3.5;
    double xHeightRatio = 0.75;
    double yHeightRatio = 2.3;
    double yWidthRatio = 0.75;

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              TimetableGridBox(
                gridBoxType: GridBoxType.placeholderBox,
                heightRatio: xHeightRatio,
                widthRatio: yWidthRatio * 2,
              ),
              TimetableGridBox(
                gridBoxType: GridBoxType.axisBox,
                initialDisplay: getAxisTypeStr(_axes.xDataAxis),
                gridAxis: GridAxis.x,
                heightRatio: xHeightRatio,
                widthRatio: totalWidthRatio - yWidthRatio * 2,
                editingForAxisBox: widget.editing,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              TimetableGridBox(
                gridBoxType: GridBoxType.axisBox,
                initialDisplay: getAxisTypeStr(_axes.yDataAxis),
                gridAxis: GridAxis.y,
                heightRatio: yHeightRatio,
                widthRatio: yWidthRatio,
                editingForAxisBox: widget.editing,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TimetableGridBox(
                    gridBoxType: GridBoxType.axisBox,
                    initialDisplay: getAxisTypeStr(_axes.zDataAxis),
                    gridAxis: GridAxis.z,
                    heightRatio: yHeightRatio / 2,
                    widthRatio: yWidthRatio,
                    editingForAxisBox: widget.editing,
                  ),
                  TimetableGridBox(
                    gridBoxType: GridBoxType.axisBox,
                    initialDisplay: getAxisTypeStr(_axes.zDataAxis),
                    gridAxis: GridAxis.z,
                    heightRatio: yHeightRatio / 2,
                    widthRatio: yWidthRatio,
                    editingForAxisBox: widget.editing,
                  ),
                ],
              ),
              TimetableGridBox(
                gridBoxType: GridBoxType.placeholderBox,
                heightRatio: yHeightRatio,
                widthRatio: totalWidthRatio - yWidthRatio * 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TimetableStatus ttbStatus = Provider.of<TimetableStatus>(context);
    _axes = widget.editing ? ttbStatus.editAxes : ttbStatus.currAxes;

    return AlertDialog(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Timetable axes',
            style: TextStyle(fontSize: 16.0),
          ),
          SizedBox(height: 5),
          Text(
            'Drag to switch axes around',
            style: textStyleBody,
          ),
        ],
      ),
      content: _generateSwitchContainer(context),
      actions: <Widget>[
        FlatButton(
          child: Text('BACK'),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}
