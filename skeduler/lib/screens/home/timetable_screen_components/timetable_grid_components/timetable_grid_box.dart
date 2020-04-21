import 'package:flutter/material.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:theme_provider/theme_provider.dart';

class TimetableGridBox extends StatelessWidget {
  /// properties
  final BuildContext context;
  final String display;
  final int flex;
  final bool content;

  /// constructors
  const TimetableGridBox(
    this.context,
    this.display, {
    this.flex = 1,
    this.content = false,
    Key key,
  }) : super(key: key);

  /// methods
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.all(2.0),
        child: Container(
          alignment: Alignment.center,
          constraints: BoxConstraints.expand(),
          padding: EdgeInsets.all(2.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: content
                  ? getOriginThemeData(ThemeProvider.themeOf(context).id)
                      .primaryColorLight
                  : getOriginThemeData(ThemeProvider.themeOf(context).id)
                      .primaryColor),
          child: Text(
            display ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 10.0),
          ),
        ),
      ),
    );
  }
}
