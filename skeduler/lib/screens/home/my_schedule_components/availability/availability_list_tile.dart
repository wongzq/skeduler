import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:skeduler/shared/widgets/edit_time_dialog.dart';

class AvailabilityListTile extends StatelessWidget {
  final bool alwaysAvailable;
  final Time time;

  AvailabilityListTile({
    Key key,
    @required this.alwaysAvailable,
    @required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    OriginTheme originTheme = Provider.of<OriginTheme>(context);
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return Container(
      child: Column(
        children: <Widget>[
          Divider(height: 1.0),
          // Custom List Tile
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Left section
              // Display Day Month
              // Display Weekday
              Container(
                padding: EdgeInsets.fromLTRB(20.0, 15.0, 0.0, 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      DateFormat('dd MMM').format(time.startTime),
                      style: textStyleBody.copyWith(fontSize: 15.0),
                    ),
                    Text(
                      DateFormat('EEEE').format(time.startTime),
                      style: textStyleBodyLight.copyWith(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey.shade600
                            : Colors.grey,
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
              ),

              // Right section
              // Display Start Time to End Time
              Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: originTheme.primaryColorLight,
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
                      DateFormat('hh:mm aa').format(time.startTime),
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(7.5),
                    child: Text('to'),
                  ),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: originTheme.primaryColorLight,
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
                      DateFormat('hh:mm aa').format(time.endTime),
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),

                  // Display Options
                  PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert,
                    ),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.edit),
                              SizedBox(width: 10.0),
                              Text('Edit'),
                            ],
                          ),
                          value: AvailabilityOption.edit,
                        ),
                        PopupMenuItem(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.delete),
                              SizedBox(width: 10.0),
                              Text('Remove'),
                            ],
                          ),
                          value: AvailabilityOption.remove,
                        ),
                      ];
                    },
                    onSelected: (value) async {
                      switch (value) {
                        case AvailabilityOption.edit:
                          await showDialog(
                            context: context,
                            builder: (context) {
                              DateTime newStartTime = time.startTime;
                              DateTime newEndTime = time.endTime;

                              return EditTimeDialog(
                                contentText: 'Edit time',
                                initialStartTime: time.startTime,
                                initialEndTime: time.endTime,
                                valSetStartTime: (dateTime) =>
                                    newStartTime = dateTime,
                                valSetEndTime: (dateTime) =>
                                    newEndTime = dateTime,
                                onSave: () async {
                                  await dbService.updateGroupMemberTimes(
                                    groupStatus.group.docId,
                                    null,
                                    [
                                      Time(
                                        startTime: newStartTime,
                                        endTime: newEndTime,
                                      ),
                                    ],
                                    groupStatus.me.alwaysAvailable,
                                  );
                                },
                              );
                            },
                          );
                          break;

                        case AvailabilityOption.remove:
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            'Remove this from your schedule?\n\n',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: DateFormat('EEEE, d MMMM')
                                            .format(time.startTime),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('CANCEL'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  FlatButton(
                                    child: Text(
                                      'REMOVE',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                    onPressed: () async {
                                      await dbService.removeGroupMemberTimes(
                                        groupStatus.group.docId,
                                        null,
                                        [time],
                                        alwaysAvailable,
                                      );
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                          break;
                      }
                    },
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
