import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/day_editor.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/editors_status.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/month_editor.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/time_editor.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/ui_settings.dart';

class ScheduleEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);

    List<Month> _monthsSelected = [];
    List<Weekday> _weekdaysSelected = [];

    EditorsStatus editorsStatus =
        EditorsStatus(currentEditor: CurrentEditor.month);

    return StreamBuilder<Object>(
        stream: dbService.getGroup(groupDocId.value),
        builder: (context, snapshot) {
          Group group = snapshot != null ? snapshot.data : null;

          return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: group.name == null
                  ? Text(
                      'My Schedule',
                      style: textStyleAppBarTitle,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          group.name,
                          style: textStyleAppBarTitle,
                        ),
                        Text(
                          'My Schedule',
                          style: textStyleBody,
                        )
                      ],
                    ),
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  editorsStatus.totalHeight = constraints.maxHeight;
                  editorsStatus.totalWidth = constraints.maxWidth;

                  editorsStatus.dividerHeight = 16.0;
                  editorsStatus.defaultSecondaryHeight = 55.0;
                  editorsStatus.defaultPrimaryHeight =
                      editorsStatus.totalHeight -
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
                          valSetMonths: (monthsSelected) {
                            _monthsSelected = monthsSelected;
                            _monthsSelected
                                .sort((a, b) => a.index.compareTo(b.index));
                          },
                        ),
                        Divider(
                            thickness: 1.0,
                            height: editorsStatus.dividerHeight),

                        /// Day Editor
                        DayEditor(
                          valSetWeekdays: (weekdaysSelected) {
                            _weekdaysSelected = weekdaysSelected;
                            _weekdaysSelected
                                .sort((a, b) => a.index.compareTo(b.index));
                          },
                          valGetMonths: () => _monthsSelected,
                        ),
                        Divider(
                            thickness: 1.0,
                            height: editorsStatus.dividerHeight),

                        /// Time Editor
                        TimeEditor(
                          valGetMonths: () => _monthsSelected,
                          valGetWeekdays: () => _weekdaysSelected,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        });
  }
}
