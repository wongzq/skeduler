import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/screens/home/profile_screen_components/day_editor.dart';
import 'package:skeduler/screens/home/profile_screen_components/editors_status.dart';
import 'package:skeduler/screens/home/profile_screen_components/month_editor.dart';
import 'package:skeduler/screens/home/profile_screen_components/time_editor.dart';

class ScheduleTab extends StatelessWidget {
  // final MonthEditor _monthEditor = MonthEditor();
  // final DayEditor _dayEditor = DayEditor();
  // final TimeEditor _timeEditor = TimeEditor();

  @override
  Widget build(BuildContext context) {
    List<Month> _monthsSelected = [];
    List<Weekday> _weekdaysSelected = [];

    EditorsStatus editorsStatus =
        EditorsStatus(currentEditor: CurrentEditor.month);

    return LayoutBuilder(
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
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            children: <Widget>[
              /// Month Editor
              MonthEditor(
                valueSetterMonths: (monthsSelected) {
                  _monthsSelected = monthsSelected;
                  _monthsSelected.sort((a, b) => a.index.compareTo(b.index));
                },
              ),
              Divider(thickness: 1.0, height: editorsStatus.dividerHeight),

              /// Day Editor
              DayEditor(
                valueSetterWeekdays: (weekdaysSelected) {
                  _weekdaysSelected = weekdaysSelected;
                  _weekdaysSelected.sort((a, b) => a.index.compareTo(b.index));
                },
                valueGetterMonths: () => _monthsSelected,
              ),
              Divider(thickness: 1.0, height: editorsStatus.dividerHeight),

              /// Time Editor
              TimeEditor(
                valueGetterMonths: () => _monthsSelected,
                valueGetterWeekdays: () => _weekdaysSelected,
              ),
            ],
          ),
        );
      },
    );
  }
}
