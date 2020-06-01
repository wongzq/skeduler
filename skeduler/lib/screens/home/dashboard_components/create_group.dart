import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/firestore/user.dart';
import 'package:skeduler/screens/home/dashboard_components/group_card.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/widgets/color_selector.dart';
import 'package:skeduler/shared/widgets/label_text_input.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class CreateGroup extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  // properties
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _nameValid = false;
  bool _descValid = true;

  String _groupName;
  String _groupDescription;

  ColorShade _groupColorShade = ColorShade();

  String _groupOwnerEmail;
  String _groupOwnerName;

  // methods
  @override
  Widget build(BuildContext context) {
    User owner = Provider.of<User>(context);
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    OriginTheme originTheme = Provider.of<OriginTheme>(context);

    if (owner != null) {
      _groupOwnerEmail = owner.email;
      _groupOwnerName = owner.name;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        title: AppBarTitle(title: 'Create group'),
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'Create Group Cancel',
            backgroundColor: Colors.red,
            child: Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          SizedBox(width: 20.0),
          FloatingActionButton(
            heroTag: 'Create Group Confirm',
            backgroundColor:
                _nameValid && _descValid ? Colors.green : Colors.grey,
            child: Icon(
              Icons.check,
              color: Colors.white,
            ),
            onPressed: _nameValid && _descValid
                ? () async {
                    unfocus();

                    _scaffoldKey.currentState.showSnackBar(
                        LoadingSnackBar(context, 'Creating group . . .'));

                    await dbService
                        .createGroup(
                      _groupName,
                      _groupDescription,
                      _groupColorShade,
                      _groupOwnerEmail,
                      _groupOwnerName,
                    )
                        .then((_) {
                      _scaffoldKey.currentState.hideCurrentSnackBar();
                      Navigator.of(context)
                          .popUntil((route) => !route.navigator.canPop());
                    });
                  }
                : null,
          ),
        ],
      ),

      // Body
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => unfocus(),
        child: Column(
          children: <Widget>[
            // Required fields
            // Name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: LabelTextInput(
                hintText: 'Required',
                label: 'Name',
                valSetText: (value) {
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

            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: LabelTextInput(
                hintText: 'Optional',
                label: 'Description',
                valSetText: (value) {
                  setState(() {
                    _groupDescription = value;
                    _descValid = value == null || value.trim().length == 0
                        ? value.trim().length >= 100 ? false : true
                        : true;
                  });
                },
              ),
            ),

            // Color
            ColorSelector(
              valSetColorShade: (value) {
                setState(() => _groupColorShade = value);
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

            // Preview
            GroupCard(
              groupName: _groupName,
              ownerName: _groupOwnerName,
              groupColor: () {
                if (_groupColorShade.color == null) {
                  _groupColorShade.color = originTheme.primaryColor;
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
