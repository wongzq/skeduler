import 'package:flutter/cupertino.dart';

enum DrawerEnums {
  dashboard,
  group,
  people,
  classes,
  timetable,
  profile,
  settings,
  logout,
}

class DrawerEnum extends ChangeNotifier {
  DrawerEnums value;

  DrawerEnum(this.value);
}