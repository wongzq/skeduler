import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/conflict.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/shared/ui_settings.dart';

class ConflictListTile extends StatelessWidget {
  final Conflict conflict;

  ConflictListTile({
    Key key,
    @required this.conflict,
  }) : super(key: key);

  String _generateConflictDates() {
    String conflictDatesStr = '';
    for (DateTime date in conflict.conflictDates) {
      conflictDatesStr += DateFormat('dd MMM').format(date);
      if (date != conflict.conflictDates.last) {
        conflictDatesStr += ', ';
      }
    }
    return conflictDatesStr;
  }

  // methods
  @override
  Widget build(BuildContext context) {
    OriginTheme originTheme = Provider.of<OriginTheme>(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey
                : Colors.black,
            blurRadius: 1.0,
            offset: Offset(0.0, 2.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Member information
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: conflict.member.name +
                            ' (' +
                            conflict.member.nickname +
                            ')',
                        style: textStyleBody.copyWith(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                          fontSize: 15.0,
                        ),
                      ),
                      TextSpan(
                        text: '  is not available on',
                        style: textStyleBody.copyWith(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey.shade600
                                  : Colors.grey,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  child: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.shade600
                        : Colors.grey,
                  ),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: ConflictOption.keep,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.check),
                            SizedBox(width: 10.0),
                            Text('Keep'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: ConflictOption.remove,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.delete),
                            SizedBox(width: 10.0),
                            Text('Remove'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: ConflictOption.editTimetable,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.table_chart),
                            SizedBox(width: 10.0),
                            Text('Edit Timetable'),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),

          // Dates
          Container(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: Text(
                getWeekdayStr(conflict.gridData.coord.day) +
                    ', ' +
                    _generateConflictDates(),
                style: textStyleBodyLight.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.shade600
                      : Colors.grey,
                  fontSize: 13.0,
                ),
              ),
            ),
          ),

          // Schedule information
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: originTheme.primaryColorLight,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left section
                // Display Custom : Subjects
                // Display Weekday, Day Month
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      conflict.gridData.coord.custom ?? '',
                      style: textStyleBodyLight.copyWith(
                        color: Colors.black,
                        fontSize: 13.0,
                      ),
                      overflow: TextOverflow.fade,
                    ),
                    Text(
                      conflict.gridData.dragData.subject.display ?? '',
                      style: textStyleBodyLight.copyWith(
                        color: Colors.black,
                        fontSize: 13.0,
                      ),
                      overflow: TextOverflow.fade,
                    ),
                  ],
                ),

                // Right section
                // Display Start Time to End Time
                Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(50.0),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey
                                    : Colors.transparent,
                            blurRadius: 1.0,
                            offset: Offset(0.0, 2.0),
                          ),
                        ],
                      ),
                      child: Text(
                        conflict.gridData.coord.time.startTimeStr,
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(7.5),
                      child: Text(
                        'to',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(50.0),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey
                                    : Colors.transparent,
                            blurRadius: 1.0,
                            offset: Offset(0.0, 2.0),
                          ),
                        ],
                      ),
                      child: Text(
                        conflict.gridData.coord.time.endTimeStr,
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
