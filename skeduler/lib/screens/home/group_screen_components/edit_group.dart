import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/group_card.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/color_selector.dart';
import 'package:skeduler/shared/components/label_text_input.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:theme_provider/theme_provider.dart';

class EditGroup extends StatefulWidget {
  final Group group;

  const EditGroup(this.group);

  @override
  _EditGroupState createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
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
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GlobalKey<FormState> _formKeyName = GlobalKey<FormState>();
    GlobalKey<FormState> _formKeyDesc = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Group',
          style: textStyleAppBarTitle,
        ),
      ),
      body: Stack(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => unfocus(),
            child: Column(
              children: <Widget>[
                /// Required fields
                /// Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
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

                /// Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
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

                /// Color
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

                      /// Preview
                      GroupCard(
                        groupName: _groupName,
                        ownerName: _groupOwnerName,
                        groupColor: () {
                          if (_groupColorShade.color == null) {
                            _groupColorShade.color = getOriginThemeData(
                                    ThemeProvider.themeOf(context).id)
                                .primaryColor;
                          }
                          return _groupColorShade.color;
                        }(),
                        hasNotification: false,
                      ),
                      Divider(thickness: 1.0),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// Editing mode
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  /// Cancel changes
                  FloatingActionButton(
                    heroTag: 'Cancel',
                    backgroundColor: Colors.red,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(width: 20.0),

                  /// Confirm amd make changes
                  FloatingActionButton(
                    heroTag: 'Confirm',
                    backgroundColor: Colors.green,
                    onPressed: () {
                      if (_formKeyName.currentState.validate() &&
                          _formKeyDesc.currentState.validate()) {
                        if (_groupName.trim() != widget.group.name ||
                            _groupDescription.trim() !=
                                widget.group.description ||
                            _groupColorShade.themeId !=
                                widget.group.colorShade.themeId ||
                            _groupColorShade.shade !=
                                widget.group.colorShade.shade) {
                          dbService.updateGroupData(
                            widget.group.groupDocId,
                            name: _groupName.trim(),
                            description: _groupDescription.trim(),
                            colorShade: _groupColorShade,
                            ownerName: _groupOwnerName.trim(),
                            ownerEmail: _groupOwnerEmail.trim(),
                          );
                        }
                        Navigator.of(context).pop();
                      }
                    },
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
