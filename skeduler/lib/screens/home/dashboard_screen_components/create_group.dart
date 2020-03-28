import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/change_colour.dart';
import 'package:skeduler/shared/ui_settings.dart';

class CreateGroup extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  bool _valid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create group',
          style: appBarTitleTextStyle,
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.0),
            child: FlatButton(
              child: Icon(Icons.create),
              onPressed: _valid ? () {} : null,
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Text(''),
          ChangeColour(),
        ],
          // Name
          // Color

          // Description: optional
          // Timetable settings: Custom time settings
            // Timetable settings: Days per week
            // Timetable settings: Classes per day
            // Timetable settings: Add custom time
          ),
    );
  }
}
