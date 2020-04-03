import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/color_shade.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/group_card.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/change_color.dart';
import 'package:skeduler/shared/components/label_text_input.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:theme_provider/theme_provider.dart';

class CreateGroup extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  /// properties
  bool _nameValid = false;
  bool _descValid = true;

  String _groupName;
  String _groupDescription;

  ColorShade _groupColorShade = ColorShade();

  String _groupOwnerEmail;
  String _groupOwnerName;

  /// methods
  @override
  Widget build(BuildContext context) {
    User owner = Provider.of<User>(context);
    DatabaseService dbService = Provider.of<DatabaseService>(context);

    if (owner != null) {
      _groupOwnerEmail = owner.email;
      _groupOwnerName = owner.name;
    }

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
          style: textStyleAppBarTitle,
        ),

        /// Icon: Tick to update
        actions: <Widget>[
          FlatButton(
            child: Icon(
              Icons.check,
              color: _nameValid && _descValid ? Colors.green : null,
            ),
            onPressed: _nameValid && _descValid
                ? () {
                    dbService.setGroupData(
                      _groupName,
                      _groupDescription,
                      _groupColorShade,
                      _groupOwnerEmail,
                      _groupOwnerName,
                    );
                    Navigator.of(context).pop();
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: LabelTextInput(
                hintText: 'Required',
                label: 'Name',
                valueSetterText: (value) {
                  setState(() {
                    _groupName = value;
                    _nameValid = value == null ||
                            value.trim().length == 0 ||
                            value.trim().length > 30
                        ? false
                        : true;
                  });
                },
              ),
            ),

            /// Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: LabelTextInput(
                hintText: 'Optional',
                label: 'Description',
                valueSetterText: (value) {
                  setState(() {
                    _groupDescription = value;
                    _descValid = value == null || value.trim().length == 0
                        ? value.trim().length >= 100 ? false : true
                        : true;
                  });
                },
              ),
            ),

            /// Color
            ChangeColor(
              valueSetterColorShade: (value) {
                setState(() {
                  _groupColorShade = value;
                });
              },
            ),

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
                      getOriginThemeData(ThemeProvider.themeOf(context).id)
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
