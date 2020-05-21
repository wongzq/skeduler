import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/edit_time_dialog.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:theme_provider/theme_provider.dart';

enum AvailabilityOption { edit, remove }

class AvailabilityView extends StatefulWidget {
  @override
  _AvailabilityViewState createState() => _AvailabilityViewState();
}

class _AvailabilityViewState extends State<AvailabilityView> {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    bool alwaysAvailable = groupStatus.me.alwaysAvailable;

    return groupStatus.me == null
        ? Container()
        : Column(
            children: <Widget>[
              // Switch default availability
              Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 5.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Always available',
                        style: alwaysAvailable
                            ? textStyleBody
                            : textStyleBody.copyWith(color: Colors.grey),
                      ),
                      Switch(
                        activeColor: getOriginThemeData(
                                ThemeProvider.themeOf(context).id)
                            .accentColor,
                        value: alwaysAvailable,
                        onChanged: (value) async {
                          await dbService
                              .updateGroupMemberAlwaysAvailable(
                                groupStatus.group.docId,
                                null,
                                value,
                              )
                              .then((_) => setState(() {}));
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // if times is empty
              () {
                return alwaysAvailable
                    ? groupStatus.me.notAvailableTimes.length == 0
                    : groupStatus.me.times.length == 0;
              }()
                  ? Expanded(
                      child: ListView(
                        children: <Widget>[
                          Container(
                            child: Column(
                              children: <Widget>[
                                // Header
                                Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text(
                                        alwaysAvailable
                                            ? 'NO UNAVAILABLE TIMES'
                                            : 'NO AVAILABLE TIMES',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 16.0,
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                                    ),
                                    Divider(thickness: 1.0),
                                  ],
                                ),

                                // Custom List Tile with Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    // Left section
                                    Container(
                                      padding: EdgeInsets.fromLTRB(
                                          20.0, 10.0, 0.0, 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Example',
                                            style: textStyleBody.copyWith(
                                              color: Colors.grey,
                                              fontSize: 15.0,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          Text(
                                            'Time',
                                            style: textStyleBodyLight.copyWith(
                                              color: Colors.grey,
                                              fontSize: 13.0,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Right section
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.grey.shade300
                                                    : Colors.grey.shade700,
                                            borderRadius:
                                                BorderRadius.circular(50.0),
                                          ),
                                          child: Text(
                                            DateFormat('hh:mm aa')
                                                .format(DateTime.now()),
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text(
                                            'to',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.grey.shade300
                                                    : Colors.grey.shade700,
                                            borderRadius:
                                                BorderRadius.circular(50.0),
                                          ),
                                          child: Text(
                                            DateFormat('hh:mm aa').format(
                                                DateTime.now()
                                                    .add(Duration(hours: 1))),
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 30.0),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )

                  // if times is not empty
                  : Expanded(
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: alwaysAvailable
                            ? groupStatus.me.notAvailableTimes.length
                            : groupStatus.me.times.length,
                        itemBuilder: (context, index) {
                          return Container(
                            child: Column(
                              children: <Widget>[
                                // Header
                                index == 0
                                    ? Column(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.all(10.0),
                                            child: Text(
                                              (alwaysAvailable
                                                      ? 'EXCEPT FOR '
                                                      : '') +
                                                  DateFormat('MMMM')
                                                      .format(alwaysAvailable
                                                          ? groupStatus
                                                              .me
                                                              .notAvailableTimes[
                                                                  index]
                                                              .startTime
                                                          : groupStatus
                                                              .me
                                                              .times[index]
                                                              .startTime)
                                                      .toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                letterSpacing: 2.0,
                                              ),
                                            ),
                                          ),
                                          Divider(thickness: 1.0),
                                        ],
                                      )
                                    : Container(),
                                index > 0 &&
                                        () {
                                          return alwaysAvailable
                                              ? groupStatus
                                                      .me
                                                      .notAvailableTimes[
                                                          index - 1]
                                                      .startTime
                                                      .month !=
                                                  groupStatus
                                                      .me
                                                      .notAvailableTimes[index]
                                                      .startTime
                                                      .month
                                              : groupStatus.me.times[index - 1]
                                                      .startTime.month !=
                                                  groupStatus.me.times[index]
                                                      .startTime.month;
                                        }()
                                    ? Column(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.all(10.0),
                                            child: Text(
                                              (alwaysAvailable
                                                      ? 'EXCEPT FOR '
                                                      : '') +
                                                  DateFormat('MMMM')
                                                      .format(alwaysAvailable
                                                          ? groupStatus
                                                              .me
                                                              .notAvailableTimes[
                                                                  index]
                                                              .startTime
                                                          : groupStatus
                                                              .me
                                                              .times[index]
                                                              .startTime)
                                                      .toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                letterSpacing: 2.0,
                                              ),
                                            ),
                                          ),
                                          Divider(thickness: 1.0),
                                        ],
                                      )
                                    : Container(),

                                // Custom List Tile
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    // Left section
                                    Container(
                                      padding: EdgeInsets.fromLTRB(
                                          20.0, 10.0, 0.0, 10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            DateFormat('dd MMM').format(
                                                alwaysAvailable
                                                    ? groupStatus
                                                        .me
                                                        .notAvailableTimes[
                                                            index]
                                                        .startTime
                                                    : groupStatus
                                                        .me
                                                        .times[index]
                                                        .startTime),
                                            style: textStyleBody.copyWith(
                                                fontSize: 15.0),
                                          ),
                                          Text(
                                            DateFormat('EEEE').format(
                                                alwaysAvailable
                                                    ? groupStatus
                                                        .me
                                                        .notAvailableTimes[
                                                            index]
                                                        .startTime
                                                    : groupStatus
                                                        .me
                                                        .times[index]
                                                        .startTime),
                                            style: textStyleBodyLight.copyWith(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Colors.grey.shade600
                                                  : Colors.grey,
                                              fontSize: 13.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Right section
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            color: getOriginThemeData(
                                                    ThemeProvider.themeOf(
                                                            context)
                                                        .id)
                                                .primaryColorLight,
                                            borderRadius:
                                                BorderRadius.circular(50.0),
                                          ),
                                          child: Text(
                                            DateFormat('hh:mm aa').format(
                                                alwaysAvailable
                                                    ? groupStatus
                                                        .me
                                                        .notAvailableTimes[
                                                            index]
                                                        .startTime
                                                    : groupStatus
                                                        .me
                                                        .times[index]
                                                        .startTime),
                                            style: TextStyle(
                                              color: Colors.black,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text('to'),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            color: getOriginThemeData(
                                                    ThemeProvider.themeOf(
                                                            context)
                                                        .id)
                                                .primaryColorLight,
                                            borderRadius:
                                                BorderRadius.circular(50.0),
                                          ),
                                          child: Text(
                                            DateFormat('hh:mm aa').format(
                                                alwaysAvailable
                                                    ? groupStatus
                                                        .me
                                                        .notAvailableTimes[
                                                            index]
                                                        .endTime
                                                    : groupStatus.me
                                                        .times[index].endTime),
                                            style: TextStyle(
                                              color: Colors.black,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
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
                                                value:
                                                    AvailabilityOption.remove,
                                              ),
                                            ];
                                          },
                                          onSelected: (val) async {
                                            switch (val) {
                                              case AvailabilityOption.edit:
                                                await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    DateTime newStartTime =
                                                        alwaysAvailable
                                                            ? groupStatus
                                                                .me
                                                                .notAvailableTimes[
                                                                    index]
                                                                .startTime
                                                            : groupStatus
                                                                .me
                                                                .times[index]
                                                                .startTime;
                                                    DateTime newEndTime =
                                                        alwaysAvailable
                                                            ? groupStatus
                                                                .me
                                                                .notAvailableTimes[
                                                                    index]
                                                                .endTime
                                                            : groupStatus
                                                                .me
                                                                .times[index]
                                                                .endTime;

                                                    return EditTimeDialog(
                                                      contentText:
                                                          'Edit schedule time',
                                                      initialStartTime:
                                                          alwaysAvailable
                                                              ? groupStatus
                                                                  .me
                                                                  .notAvailableTimes[
                                                                      index]
                                                                  .startTime
                                                              : groupStatus
                                                                  .me
                                                                  .times[index]
                                                                  .startTime,
                                                      initialEndTime:
                                                          alwaysAvailable
                                                              ? groupStatus
                                                                  .me
                                                                  .notAvailableTimes[
                                                                      index]
                                                                  .endTime
                                                              : groupStatus
                                                                  .me
                                                                  .times[index]
                                                                  .endTime,
                                                      valSetStartTime:
                                                          (dateTime) =>
                                                              newStartTime =
                                                                  dateTime,
                                                      valSetEndTime:
                                                          (dateTime) =>
                                                              newEndTime =
                                                                  dateTime,
                                                      onSave: () async {
                                                        await dbService
                                                            .updateGroupMemberTimes(
                                                          groupStatus
                                                              .group.docId,
                                                          null,
                                                          [
                                                            Time(
                                                              newStartTime,
                                                              newEndTime,
                                                            ),
                                                          ],
                                                          groupStatus.me
                                                              .alwaysAvailable,
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
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: DateFormat('EEEE, d MMMM').format(alwaysAvailable
                                                                  ? groupStatus
                                                                      .me
                                                                      .notAvailableTimes[
                                                                          index]
                                                                      .startTime
                                                                  : groupStatus
                                                                      .me
                                                                      .times[
                                                                          index]
                                                                      .startTime),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          child: Text('CANCEL'),
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                        ),
                                                        FlatButton(
                                                          child: Text(
                                                            'REMOVE',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            await dbService
                                                                .removeGroupMemberTimes(
                                                              groupStatus
                                                                  .group.docId,
                                                              null,
                                                              [
                                                                alwaysAvailable
                                                                    ? groupStatus
                                                                            .me
                                                                            .notAvailableTimes[
                                                                        index]
                                                                    : groupStatus
                                                                            .me
                                                                            .times[
                                                                        index]
                                                              ],
                                                              alwaysAvailable,
                                                            );
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
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

                                index ==
                                        () {
                                          return alwaysAvailable
                                              ? groupStatus.me.notAvailableTimes
                                                      .length -
                                                  1
                                              : groupStatus.me.times.length - 1;
                                        }()
                                    ? SizedBox(height: 100.0)
                                    : Divider(thickness: 1.0),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ],
          );
  }
}
