import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/availability_editor_components/day_editor.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/availability_editor_components/editors_status.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/availability_editor_components/month_editor.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/availability_editor_components/time_editor.dart';
import 'package:skeduler/shared/widgets.dart';

class AvailabilityEditor extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    List<Month> _monthsSelected = [];
    List<Weekday> _weekdaysSelected = [];

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
