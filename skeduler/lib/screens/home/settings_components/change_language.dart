import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/custom_enums.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/auxiliary/preferences.dart';

class ChangeLanguage extends StatefulWidget {
  @override
  _ChangeLanguageState createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> {
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
              'Language',
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Text(
                preferences == null ? '' : languageString(preferences.language),
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
                Language selected = preferences.language;

                return AlertDialog(
                  title: Text('Language'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: Language.values
                        .map(
                          (language) => RadioListTile<Language>(
                            activeColor: originTheme.accentColor,
                            title: Text(languageString(language)),
                            value: language,
                            groupValue: selected,
                            onChanged: (value) async {
                              await preferences.setLanguage(value);
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
