import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/auxiliary/time.dart';
import 'package:skeduler/screens/home/schedules_components/availability/availability_list_tile.dart';

class AvailabilityExpansionTile extends StatefulWidget {
  final int monthIndex;
  final List<Time> times;

  const AvailabilityExpansionTile({
    Key key,
    @required this.monthIndex,
    @required this.times,
  }) : super(key: key);

  @override
  _AvailabilityExpansionTileState createState() =>
      _AvailabilityExpansionTileState();
}

class _AvailabilityExpansionTileState
    extends State<AvailabilityExpansionTile> {
  bool _expanded;

  List<Widget> _generateAvailabilityListTiles(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    List<Widget> availabilityWidgets = [];

    for (Time time in widget.times) {
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
            accentColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
          ),
          child: ExpansionTile(
            key: GlobalKey(),
            onExpansionChanged: (value) => _expanded = value,
            initiallyExpanded:
                _expanded ?? DateTime.now().month == widget.monthIndex,
            title: Container(
              padding: EdgeInsets.all(5.0),
              child: Text(
                groupStatus.member.alwaysAvailable
                    ? 'EXCEPT FOR ' +
                        getMonthStr(Month.values[widget.monthIndex - 1])
                            .toUpperCase()
                    : getMonthStr(Month.values[widget.monthIndex - 1])
                        .toUpperCase(),
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
