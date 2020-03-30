import 'package:flutter/material.dart';
import 'package:skeduler/screens/home/settings_screen_components/change_theme.dart';
import 'package:skeduler/screens/home/settings_screen_components/change_user_data.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ChangeUserData(),
        Divider(),
        ChangeTheme(),
      ],
    );
  }
}
