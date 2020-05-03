import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid_box.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimetableSwitchDialog extends StatefulWidget {
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
                initialDisplay: getAxisTypeStr(_axes.xType),
                gridAxisType: GridAxisType.x,
                heightRatio: xHeightRatio,
                widthRatio: totalWidthRatio - yWidthRatio * 2,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              TimetableGridBox(
                gridBoxType: GridBoxType.axisBox,
                initialDisplay: getAxisTypeStr(_axes.yType),
                gridAxisType: GridAxisType.y,
                heightRatio: yHeightRatio,
                widthRatio: yWidthRatio,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TimetableGridBox(
                    gridBoxType: GridBoxType.axisBox,
                    initialDisplay: getAxisTypeStr(_axes.zType),
                    gridAxisType: GridAxisType.z,
                    heightRatio: yHeightRatio / 2,
                    widthRatio: yWidthRatio,
                  ),
                  TimetableGridBox(
                    gridBoxType: GridBoxType.axisBox,
                    initialDisplay: getAxisTypeStr(_axes.zType),
                    gridAxisType: GridAxisType.z,
                    heightRatio: yHeightRatio / 2,
                    widthRatio: yWidthRatio,
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
    _axes = Provider.of<TimetableAxes>(context);

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
            'Drag to switch axis around',
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
