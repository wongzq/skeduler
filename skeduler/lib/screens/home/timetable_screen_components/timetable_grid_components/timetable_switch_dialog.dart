import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/timetable.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid_box.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimetableSwitchDialog extends StatefulWidget {
  final TimetableAxes initialAxes;
  final ValueSetter<TimetableAxes> valSetAxes;

  const TimetableSwitchDialog({
    Key key,
    @required this.initialAxes,
    this.valSetAxes,
  }) : super(key: key);

  @override
  _TimetableSwitchDialogState createState() => _TimetableSwitchDialogState();
}

class _TimetableSwitchDialogState extends State<TimetableSwitchDialog> {
  TimetableAxes _axes;

  Widget _generateSwitchContainer(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.width * 0.5,
      child: Flex(
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                TimetableGridBox(
                  context: context,
                  initialDisplay: '',
                  type: GridBoxType.placeholderBox,
                  flex: 2,
                ),
                TimetableGridBox(
                  context: context,
                  initialDisplay: getAxisTypeStr(_axes.xType),
                  type: GridBoxType.axisBox,
                  gridAxisType: GridAxisType.x,
                  flex: 3,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Flex(
              direction: Axis.horizontal,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      TimetableGridBox(
                        context: context,
                        initialDisplay: getAxisTypeStr(_axes.yType),
                        type: GridBoxType.axisBox,
                        gridAxisType: GridAxisType.y,
                        flex: 1,
                      ),
                      Expanded(
                        flex: 1,
                        child: Flex(
                          direction: Axis.vertical,
                          children: <Widget>[
                            TimetableGridBox(
                              context: context,
                              initialDisplay: getAxisTypeStr(_axes.zType),
                              type: GridBoxType.axisBox,
                              gridAxisType: GridAxisType.z,
                              flex: 1,
                            ),
                            TimetableGridBox(
                              context: context,
                              initialDisplay: getAxisTypeStr(_axes.zType),
                              type: GridBoxType.axisBox,
                              gridAxisType: GridAxisType.z,
                              flex: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                TimetableGridBox(
                  context: context,
                  initialDisplay: '',
                  type: GridBoxType.placeholderBox,
                  flex: 3,
                ),
              ],
            ),
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