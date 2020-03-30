import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/native_theme.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/change_color.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/group_card.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/label_text_input.dart';
import 'package:skeduler/shared/ui_settings.dart';

class CreateGroup extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  bool _valid = false;
  String _groupName;
  String _groupDescription;
  Color _groupColor;
  String _ownerName;

  @override
  Widget build(BuildContext context) {
    _ownerName = Provider.of<User>(context).name;
    TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => unfocus(),
        child: Column(
          children: <Widget>[
            /// Required fields
            /// Name
            LabelTextInput(
              hintText: 'Required',
              label: 'Name',
              valueSetter: (value) {
                setState(() {
                  _groupName = value;
                });
              },
            ),

            /// Description
            LabelTextInput(
              hintText: 'Optional',
              label: 'Description',
              valueSetter: (value) {
                setState(() {
                  _groupDescription = value;
                });
              },
            ),

            /// Color
            ChangeColor(valueSetter: (value) {
              setState(() {
                _groupColor = value;
              });
            }),

            Divider(thickness: 1.0),
            SizedBox(height: 10.0),
            Text(
              'Preview in dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15.0,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 10.0),

            /// Preview
            GroupCard(
              groupName: _groupName,
              ownerName: _ownerName,
              groupColor:
                  _groupColor ?? Provider.of<NativeTheme>(context).primaryColor,
              hasNotification: false,
            ),
          ],
        ),
      ),
    );
  }
}
