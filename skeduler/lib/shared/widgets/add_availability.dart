import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/screens/home/my_schedule_components/availability/date_selector.dart';
import 'package:skeduler/screens/home/my_schedule_components/availability/time_selector.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class AddAvailability extends StatefulWidget {
  @override
  _AddAvailabilityState createState() => _AddAvailabilityState();
}

class _AddAvailabilityState extends State<AddAvailability> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime _date;
  DateTime _startTime;
  DateTime _endTime;

  bool _validDate = false;
  bool _validTime = false;

  double _spacing = 5;
  double _centerWidth = 20;

  @override
  Widget build(BuildContext context) {
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);
    DatabaseService dbService = Provider.of<DatabaseService>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: AppBarTitle(
          title: groupStatus.group.name,
          subtitle: groupStatus.me.alwaysAvailable
              ? 'Add availability exception'
              : 'Add availability',
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          // Cancel changes
          FloatingActionButton(
            heroTag: 'Add Availability Cancel',
            backgroundColor: Colors.red,
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            child: Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),

          SizedBox(width: 20.0),

          // Confirm amd make changes
          FloatingActionButton(
            heroTag: 'Add Availability Confirm',
            backgroundColor:
                _validTime && _validDate ? Colors.green : Colors.grey,
            onPressed: () async {
              unfocus();

              _scaffoldKey.currentState
                  .showSnackBar(LoadingSnackBar(context, 'Adding time . . .'));

              Time newTime = Time(
                startTime: DateTime(
                  _date.year,
                  _date.month,
                  _date.day,
                  _startTime.hour,
                  _startTime.minute,
                ),
                endTime: DateTime(
                  _date.year,
                  _date.month,
                  _date.day,
                  _endTime.hour,
                  _endTime.minute,
                ),
              );

              if (_validDate && _validTime) {
                await dbService
                    .addGroupMemberTime(
                  groupStatus.group.docId,
                  null,
                  newTime,
                  groupStatus.me.alwaysAvailable,
                )
                    .then((_) {
                  _scaffoldKey.currentState.hideCurrentSnackBar();
                  Navigator.of(context).maybePop();
                });
              }
            },
            child: Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 10.0),
          Text(
            'DATE',
            style: TextStyle(
              fontSize: 16.0,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 10.0),
          Divider(height: 1.0),
          SizedBox(height: 10.0),

          // Date Range
          // Button: Start Date
          DateSelector(
            context: context,
            type: DateSelectorType.start,
            valSetStartDate: (value) => setState(() {
              _date = value;
              _validDate = value == null ? false : true;
            }),
            valGetStartDate: () => _date,
            initialStartDate: DateTime.now(),
          ),

          SizedBox(height: 10.0),
          Divider(height: 1.0),
          SizedBox(height: 10.0),
          Text(
            'TIME RANGE',
            style: TextStyle(
              fontSize: 16.0,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 10.0),
          Divider(height: 1.0),
          SizedBox(height: 10.0),

          // Time Range
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Button: Start Time
              TimeSelector(
                context: context,
                type: TimeSelectorType.start,
                valSetStartTime: (value) => setState(() => _startTime = value),
                valSetEndTime: (value) => setState(() => _endTime = value),
                valSetValidTime: (value) => setState(() => _validTime = value),
                valGetStartTime: () => _startTime,
                valGetEndTime: () => _endTime,
              ),

              SizedBox(width: _spacing),
              Container(
                alignment: Alignment.center,
                width: _centerWidth,
                child: Text(
                  'to',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(width: _spacing),

              // Button: End Time
              TimeSelector(
                context: context,
                type: TimeSelectorType.end,
                valSetStartTime: (value) => setState(() => _startTime = value),
                valSetEndTime: (value) => setState(() => _endTime = value),
                valSetValidTime: (value) => setState(() => _validTime = value),
                valGetStartTime: () => _startTime,
                valGetEndTime: () => _endTime,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
