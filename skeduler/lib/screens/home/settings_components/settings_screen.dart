import 'package:flutter/material.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/navigation/home_drawer.dart';
import 'package:skeduler/screens/home/settings_components/change_size.dart';
import 'package:skeduler/screens/home/settings_components/change_theme.dart';
import 'package:skeduler/screens/home/settings_components/change_user_data.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: 'Settings'),
      ),
      drawer: HomeDrawer(DrawerEnum.settings),
      body: Column(
        children: <Widget>[
          ChangeUserData(),
          Divider(),
          ChangeTheme(),
          Divider(),
          ChangeSize(),
        ],
      ),
    );
  }
}
