import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/screens/home/dashboard_components/group_card.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/widgets/color_selector.dart';
import 'package:skeduler/shared/widgets/label_text_input.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class EditGroup extends StatefulWidget {
  final Group group;

  EditGroup({Key key, @required this.group}) : super(key: key);

  @override
  _EditGroupState createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _groupName;
  String _groupDescription;
  ColorShade _groupColorShade;
  String _groupOwnerName;
  String _groupOwnerEmail;

  ValueNotifier<bool> _expanded;

  @override
  void initState() {
    _groupName = widget.group.name;
    _groupDescription = widget.group.description;
    _groupColorShade = ColorShade(color: widget.group.colorShade.color);
    _groupOwnerName = widget.group.ownerName;
    _groupOwnerEmail = widget.group.ownerEmail;

    _expanded = ValueNotifier<bool>(false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    OriginTheme originTheme = Provider.of<OriginTheme>(context);
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GlobalKey<FormState> _formKeyName = GlobalKey<FormState>();
    GlobalKey<FormState> _formKeyDesc = GlobalKey<FormState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: AppBarTitle(title: 'Group')),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          // Cancel changes
          FloatingActionButton(
            heroTag: 'Edit Group Cancel',
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
            heroTag: 'Edit Group Confirm',
            backgroundColor: Colors.green,
            onPressed: () async {
              unfocus();
              
              if (_formKeyName.currentState.validate() &&
                  _formKeyDesc.currentState.validate()) {
                if (_groupName.trim() != widget.group.name ||
                    _groupDescription.trim() != widget.group.description ||
                    _groupColorShade.themeId !=
                        widget.group.colorShade.themeId ||
                    _groupColorShade.shade != widget.group.colorShade.shade) {
                  _scaffoldKey.currentState.showSnackBar(
                      LoadingSnackBar(context, 'Saving group info . . .'));

                  await dbService.updateGroupData(
                    widget.group.docId,
                    name: _groupName.trim(),
                    description: _groupDescription.trim(),
                    colorShade: _groupColorShade,
                    ownerName: _groupOwnerName.trim(),
                    ownerEmail: _groupOwnerEmail.trim(),
                  );

                  _scaffoldKey.currentState.hideCurrentSnackBar();
                }

                Navigator.of(context).maybePop();
              }
            },
            child: Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
        ],
      ),
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
                initialValue: _groupName,
                hintText: widget.group.name,
                label: 'Name',
                valSetText: (value) {
                  _groupName = value;
                },
                formKey: _formKeyName,
                validator: (value) {
                  if (value == null || value.trim().length == 0) {
                    return 'Name cannot be empty';
                  } else if (value.trim().length > 30) {
                    return 'Name must be 30 characters or less';
                  } else {
                    return null;
                  }
                },
              ),
            ),

            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: LabelTextInput(
                initialValue: _groupDescription,
                hintText: widget.group.description,
                label: 'Description',
                valSetText: (value) {
                  _groupDescription = value;
                },
                formKey: _formKeyDesc,
                validator: (value) {
                  if (value.trim().length >= 100) {
                    return 'Description must be 100 characters or less';
                  } else {
                    return null;
                  }
                },
              ),
            ),

            // Color
            Provider<bool>.value(
              value: _expanded.value,
              child: ColorSelector(
                initialValue: _groupColorShade,
                initialExpanded: _expanded.value,
                valSetColorShade: (value) {
                  setState(() {
                    _groupColorShade = value;
                  });
                },
                valSetExpanded: (value) {
                  setState(() {
                    _expanded.value = value;
                  });
                },
              ),
            ),

            Visibility(
              visible: _expanded.value,
              child: Column(
                children: <Widget>[
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
          ],
        ),
      ),
    );
  }
}
