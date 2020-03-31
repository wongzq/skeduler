import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/color_shade.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/change_color.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/group_card.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/label_text_input.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:theme_provider/theme_provider.dart';

class CreateGroup extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  /// properties
  bool _valid = false;

  String _groupName;
  String _groupDescription;

  ColorShade _groupColorShade = ColorShade();

  String _groupOwnerEmail;
  String _groupOwnerName;

  DatabaseService _dbs;

  /// methods
  @override
  Widget build(BuildContext context) {
    User _owner = Provider.of<User>(context);
    _dbs = Provider.of<DatabaseService>(context);
    _groupOwnerEmail = _owner.email;
    _groupOwnerName = _owner.name;

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

        /// Icon: Tick to update
        actions: <Widget>[
          FlatButton(
            child: Icon(
              Icons.check,
              color: _valid ? Colors.green : null,
            ),
            onPressed: _valid
                ? () {
                    _dbs.setGroupData(
                      _groupName,
                      _groupDescription,
                      _groupColorShade,
                      _groupOwnerEmail,
                      _groupOwnerName,
                    );
                  }
                : null,
          ),
        ],
      ),

      /// Body
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
                  _valid = value != null && value.trim() != '' ? true : false;
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
            ChangeColor(
              valueSetterColorShade: (value) {
                setState(() {
                  _groupColorShade = value;
                });
              },
            ),

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
              ownerName: _groupOwnerName,
              groupColor: () {
                if (_groupColorShade.color == null) {
                  _groupColorShade.color =
                      getNativeThemeData(ThemeProvider.themeOf(context).id)
                          .primaryColor;
                }
                return _groupColorShade.color;
              }(),
              hasNotification: false,
            ),
          ],
        ),
      ),
    );
  }
}
