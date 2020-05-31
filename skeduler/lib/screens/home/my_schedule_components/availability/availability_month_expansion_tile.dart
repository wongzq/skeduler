import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/screens/home/my_schedule_components/availability/availability_list_tile.dart';

class AvailabilityMonthExpansionTile extends StatelessWidget {
  final int monthIndex;
  final List<Time> times;

  const AvailabilityMonthExpansionTile({
    Key key,
    @required this.monthIndex,
    @required this.times,
  }) : super(key: key);

  List<Widget> _generateAvailabilityListTiles(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    List<Widget> availabilityWidgets = [];

    for (Time time in times) {
      availabilityWidgets.add(
        Theme(
          data: Theme.of(context),
          child: AvailabilityListTile(
            alwaysAvailable: groupStatus.me.alwaysAvailable,
            time: time,
          ),
        ),
      );
    }

    return availabilityWidgets;
  }

  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return Column(
      children: <Widget>[
        Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            accentColor: Theme.of(context).primaryTextTheme.bodyText1.color,
          ),
          child: ExpansionTile(
            initiallyExpanded: DateTime.now().month == monthIndex,
            title: Container(
              padding: EdgeInsets.all(5.0),
              child: Text(
                groupStatus.me.alwaysAvailable
                    ? 'EXCEPT FOR ' +
                        getMonthStr(Month.values[monthIndex - 1]).toUpperCase()
                    : getMonthStr(Month.values[monthIndex - 1]).toUpperCase(),
                style: TextStyle(
                  fontSize: 16.0,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            children: _generateAvailabilityListTiles(context),
          ),
        ),
        Divider(height: 1.0),
      ],
    );
  }
}
