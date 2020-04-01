import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/color_shade.dart';
import 'package:skeduler/models/group.dart';
import 'package:skeduler/screens/home/dashboard_screen_components/group_card.dart';
import 'package:skeduler/shared/change_color.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/label_text_input.dart';
import 'package:theme_provider/theme_provider.dart';

class GroupScreen extends StatefulWidget {
  final Group group;

  const GroupScreen({this.group});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  String _groupName;
  String _groupDescription;
  ColorShade _groupColorShade;
  String _groupOwnerName;

  bool _valid;
  ValueNotifier<bool> _collapsed;

  @override
  void initState() {
    _groupName = widget.group.name;
    _groupDescription = widget.group.description;
    _groupColorShade = widget.group.colorShade;
    _groupOwnerName = widget.group.ownerName;
    _collapsed = ValueNotifier<bool>(false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              valueSetter: (value) {
                setState(() {
                  _groupName = value;
                  _valid = value != null && value.trim() != '' ? true : false;
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
              valueSetter: (value) {
                setState(() {
                  _groupDescription = value;
                });
              },
            ),
          ),

          /// Color
          Provider<bool>.value(
            value: _collapsed.value,
            child: ChangeColor(
              collapseable: true,
              valueSetterColorShade: (value) {
                setState(() {
                  _groupColorShade = value;
                });
              },
              valueSetterCollapsed: (value) {
                setState(() {
                  _collapsed.value = value;
                });
              },
              initialValue: _groupColorShade,
            ),
          ),

          Visibility(
            visible: !_collapsed.value,
            child: Column(
              children: <Widget>[
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
          Divider(thickness: 1.0),
        ],
      ),
    );
  }
}
