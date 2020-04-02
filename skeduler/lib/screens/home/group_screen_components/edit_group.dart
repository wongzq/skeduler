import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/color_shade.dart';
import 'package:skeduler/models/group.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/group_card.dart';
import 'package:skeduler/shared/components/change_color.dart';
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

  ValueNotifier<bool> _expanded;

  @override
  void initState() {
    _groupName = widget.group.name;
    _groupDescription = widget.group.description;
    _groupColorShade = widget.group.colorShade;
    _groupOwnerName = widget.group.ownerName;
    _expanded = ValueNotifier<bool>(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    hintText: 'Required',
                    label: 'Name',
                    valueSetterText: (value) {
                      setState(() {
                        _groupName = value;
                      });
                    },
                  ),
                ),

                /// Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: LabelTextInput(
                    initialValue: _groupDescription,
                    hintText: 'Optional',
                    label: 'Description',
                    valueSetterText: (value) {
                      setState(() {
                        _groupDescription = value;
                      });
                    },
                  ),
                ),

                /// Color
                Provider<bool>.value(
                  value: _expanded.value,
                  child: ChangeColor(
                    initialValue: _groupColorShade,
                    initialExpanded: _expanded.value,
                    valueSetterColorShade: (value) {
                      setState(() {
                        _groupColorShade = value;
                      });
                    },
                    valueSetterExpanded: (value) {
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
                            _groupColorShade.color = getNativeThemeData(
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

          // Editing mode
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: 'Cancel',
                    backgroundColor: Colors.red,
                    onPressed: () {},
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 20.0),
                  FloatingActionButton(
                    heroTag: 'Confirm',
                    backgroundColor: Colors.green,
                    onPressed: () {},
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
