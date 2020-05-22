import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/screens/home/my_schedule_components/availability/availability_list_tile.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:theme_provider/theme_provider.dart';

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
    List<Time> times = alwaysAvailable
        ? groupStatus.me.timesUnavailable
        : groupStatus.me.timesAvailable;

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
              times.length <= 0
                  ? Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            alwaysAvailable
                                ? 'EXCEPT FOR'
                                : 'NO AVAILABLE TIMES',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16.0,
                              // fontStyle: FontStyle.italic,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                        Divider(height: 1.0),
                      ],
                    )
                  : Expanded(
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: times.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: <Widget>[
                              AvailabilityListTile(
                                alwaysAvailable: alwaysAvailable,
                                index: index,
                                time: times[index],
                                prevTime: index > 0 ? times[index - 1] : null,
                              ),
                              index == times.length - 1
                                  ? SizedBox(height: 100.0)
                                  : Divider(height: 1.0),
                            ],
                          );
                        },
                      ),
                    ),
            ],
          );
  }
}
