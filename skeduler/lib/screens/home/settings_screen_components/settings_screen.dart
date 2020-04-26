import 'package:flutter/material.dart';
import 'package:skeduler/home_drawer.dart';
import 'package:skeduler/screens/home/settings_screen_components/change_theme.dart';
import 'package:skeduler/screens/home/settings_screen_components/change_user_data.dart';
import 'package:skeduler/shared/ui_settings.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text(
          'Group',
          style: textStyleAppBarTitle,
        ),
      ),
      drawer: HomeDrawer(),
      body: Column(
        children: <Widget>[
          ChangeUserData(),
          Divider(),
          ChangeTheme(),
        ],
      ),
    );
  }
}
