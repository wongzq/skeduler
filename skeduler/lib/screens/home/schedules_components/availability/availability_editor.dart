import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/screens/home/schedules_components/availability/day_editor.dart';
import 'package:skeduler/screens/home/schedules_components/availability/editors_status.dart';
import 'package:skeduler/screens/home/schedules_components/availability/month_editor.dart';
import 'package:skeduler/screens/home/schedules_components/availability/time_editor.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class AvailabilityEditor extends StatefulWidget {
  @override
  _AvailabilityEditorState createState() => _AvailabilityEditorState();
}

class _AvailabilityEditorState extends State<AvailabilityEditor> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Month> _monthsSelected = [];
  List<Weekday> _weekdaysSelected = [];

  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    EditorsStatus editorsStatus =
        EditorsStatus(currentEditor: CurrentEditor.month);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        title: AppBarTitle(
          title: groupStatus.group.name,
          alternateTitle: 'Availability editor',
          subtitle: 'Availability editor',
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            editorsStatus.totalHeight = constraints.maxHeight;
            editorsStatus.totalWidth = constraints.maxWidth;

            editorsStatus.dividerHeight = 16.0;
            editorsStatus.defaultSecondaryHeight = 55.0;
            editorsStatus.defaultPrimaryHeight = editorsStatus.totalHeight -
                2 * editorsStatus.defaultSecondaryHeight -
                2 * editorsStatus.dividerHeight;

            return ChangeNotifierProvider(
              create: (context) => editorsStatus,
              child: ListView(
                controller: ScrollController(),
                physics: AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  // Month Editor
                  MonthEditor(
                    valSetMonths: (monthsSelected) {
                      _monthsSelected = monthsSelected;
                      _monthsSelected
                          .sort((a, b) => a.index.compareTo(b.index));
                    },
                  ),
                  Divider(thickness: 1.0, height: editorsStatus.dividerHeight),

                  // Day Editor
                  DayEditor(
                    valSetWeekdays: (weekdaysSelected) {
                      _weekdaysSelected = weekdaysSelected;
                      _weekdaysSelected
                          .sort((a, b) => a.index.compareTo(b.index));
                    },
                    valGetMonths: () => _monthsSelected,
                  ),
                  Divider(thickness: 1.0, height: editorsStatus.dividerHeight),

                  // Time Editor
                  TimeEditor(
                    scaffoldKey: _scaffoldKey,
                    valGetMonths: () {
                      _monthsSelected
                          .sort((a, b) => a.index.compareTo(b.index));
                      return _monthsSelected;
                    },
                    valGetWeekdays: () {
                      _weekdaysSelected
                          .sort((a, b) => a.index.compareTo(b.index));
                      return _weekdaysSelected;
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
