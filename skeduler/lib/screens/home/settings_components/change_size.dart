import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/auxiliary/preferences.dart';

class ChangeSize extends StatefulWidget {
  @override
  _ChangeSizeState createState() => _ChangeSizeState();
}

class _ChangeSizeState extends State<ChangeSize> {
  @override
  Widget build(BuildContext context) {
    Preferences preferences = Provider.of<Preferences>(context);
    OriginTheme originTheme = Provider.of<OriginTheme>(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Timetable Display',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Text(
                preferences == null
                    ? ''
                    : displaySizeString(preferences.displaySize),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15.0,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                DisplaySize _selected = preferences.displaySize;

                return AlertDialog(
                  title: Text('Timetable Display'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: DisplaySize.values
                        .map(
                          (displaySize) => RadioListTile<DisplaySize>(
                            activeColor: originTheme.accentColor,
                            title: Text(displaySizeString(displaySize)),
                            value: displaySize,
                            groupValue: _selected,
                            onChanged: (value) async {
                              await preferences.setDisplaySize(value);
                              setState(() {});
                            },
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            );
          },
        );
        setState(() {});
      },
    );
  }
}
