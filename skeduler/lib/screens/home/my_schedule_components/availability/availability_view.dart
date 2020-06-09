import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/screens/home/my_schedule_components/availability/availability_month_expansion_tile.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/ui_settings.dart';

class AvailabilityView extends StatefulWidget {
  @override
  _AvailabilityViewState createState() => _AvailabilityViewState();
}

class _AvailabilityViewState extends State<AvailabilityView> {
  @override
  Widget build(BuildContext context) {
    OriginTheme originTheme = Provider.of<OriginTheme>(context);
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    bool alwaysAvailable = groupStatus.member.alwaysAvailable;
    List<Time> times = alwaysAvailable
        ? groupStatus.member.timesUnavailable
        : groupStatus.member.timesAvailable;

    times.sort((a, b) => a.startTimeInt.compareTo(b.startTimeInt));

    Map<int, List<Time>> availabilityMonths = {};

    for (Time time in times) {
      if (availabilityMonths.containsKey(time.startTime.month)) {
        availabilityMonths[time.startTime.month].add(time);
      } else {
        availabilityMonths[time.startTime.month] = [];
        availabilityMonths[time.startTime.month].add(time);
      }
    }

    return groupStatus.member == null
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
                        'only available on',
                        overflow: TextOverflow.fade,
                        style: alwaysAvailable
                            ? textStyleBody.copyWith(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                              )
                            : textStyleBody,
                      ),
                      Switch(
                        activeColor: originTheme.accentColor,
                        activeTrackColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.grey.shade400.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.5),
                        inactiveThumbColor: originTheme.accentColor,
                        inactiveTrackColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.grey.shade400.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.5),
                        value: alwaysAvailable,
                        onChanged: (value) async {
                          print(groupStatus.member.docId);
                          await dbService
                              .updateGroupMemberAlwaysAvailable(
                                groupStatus.group.docId,
                                groupStatus.member.docId,
                                value,
                              )
                              .then((_) => setState(() {}));
                        },
                      ),
                      Text(
                        ' always available',
                        overflow: TextOverflow.fade,
                        style: alwaysAvailable
                            ? textStyleBody
                            : textStyleBody.copyWith(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                              ),
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
                                ? 'NO EXCEPTIONS'
                                : 'NO AVAILABLE TIMES',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16.0,
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
                        itemCount: availabilityMonths.length + 1,
                        itemBuilder: (context, index) {
                          int monthIndex = index >= availabilityMonths.length
                              ? -1
                              : availabilityMonths.keys.elementAt(index);

                          return index >= availabilityMonths.length
                              ? SizedBox(height: 100.0)
                              : AvailabilityMonthExpansionTile(
                                  monthIndex: monthIndex,
                                  times: availabilityMonths[monthIndex],
                                );
                        },
                      ),
                    ),
            ],
          );
  }
}
