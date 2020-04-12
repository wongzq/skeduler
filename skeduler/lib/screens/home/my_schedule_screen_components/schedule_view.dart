import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:theme_provider/theme_provider.dart';

class ScheduleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);

    return StreamBuilder(
      stream: dbService.getGroupMemberMyData(groupDocId.value),
      builder: (context, snapshot) {
        Member member = snapshot.data;

        return member == null
            ? Container()
            : ListView.builder(
                physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                itemCount: member.times.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: Column(
                      children: <Widget>[
                        /// Header
                        index == 0
                            ? Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(
                                      DateFormat('MMMM')
                                          .format(member.times[index].startTime)
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
                                member.times[index - 1].startTime.month !=
                                    member.times[index].startTime.month
                            ? Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(
                                      DateFormat('MMMM')
                                          .format(member.times[index].startTime)
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

                        /// Custom List Tile
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            /// Left section
                            Container(
                              padding:
                                  EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    DateFormat('dd MMM')
                                        .format(member.times[index].startTime),
                                    style:
                                        textStyleBody.copyWith(fontSize: 15.0),
                                  ),
                                  Text(
                                    DateFormat('EEEE')
                                        .format(member.times[index].startTime),
                                    style: textStyleBodyLight.copyWith(
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.grey[600]
                                          : Colors.grey,
                                      fontSize: 13.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Right section
                            Row(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: getOriginThemeData(
                                            ThemeProvider.themeOf(context).id)
                                        .primaryColorLight,
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                  child: Text(
                                    DateFormat('hh:mm aa')
                                        .format(member.times[index].startTime),
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
                                            ThemeProvider.themeOf(context).id)
                                        .primaryColorLight,
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                  child: Text(
                                    DateFormat('hh:mm aa')
                                        .format(member.times[index].endTime),
                                    style: TextStyle(
                                      color: Colors.black,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 0.0),
                                  child: PopupMenuButton(
                                    icon: Icon(
                                      Icons.more_vert,
                                    ),
                                    itemBuilder: (context) {
                                      return [
                                        PopupMenuItem(
                                          child: Text('Edit'),
                                          value: ScheduleViewOption.edit,
                                        ),
                                        PopupMenuItem(
                                          child: Text('Remove'),
                                          value: ScheduleViewOption.remove,
                                        ),
                                      ];
                                    },
                                    onSelected: (val) {
                                      switch (val) {
                                        case ScheduleViewOption.edit:
                                          showDialog(context: null);
                                          break;
                                        case ScheduleViewOption.remove:
                                          showDialog(
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
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                            text: DateFormat(
                                                                    'EEEE, d MMMM')
                                                                .format(member
                                                                    .times[
                                                                        index]
                                                                    .startTime)),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text('CANCEL'),
                                                      onPressed: () =>
                                                          Navigator.of(context)
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
                                                            groupDocId.value,
                                                            null,
                                                            [
                                                              member
                                                                  .times[index]
                                                            ],
                                                          );
                                                          Navigator.of(context)
                                                              .pop();
                                                        }),
                                                  ],
                                                );
                                              });
                                          break;
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),

                        index == member.times.length - 1
                            ? SizedBox(height: 100.0)
                            : Divider(thickness: 1.0),
                      ],
                    ),
                  );
                },
              );
      },
    );
  }
}

enum ScheduleViewOption { edit, remove }