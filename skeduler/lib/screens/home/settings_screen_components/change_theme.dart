import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/my_app_themes.dart';
import 'package:skeduler/models/auxiliary/native_theme.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:theme_provider/theme_provider.dart';

class ChangeTheme extends StatefulWidget {
  @override
  _ChangeThemeState createState() => _ChangeThemeState();
}

class _ChangeThemeState extends State<ChangeTheme> {
  List<bool> _themePressed = List.generate(myAppThemes.length, (i) => false);
  double _bodyHoriPadding = 20.0;
  double _bodyVertPadding = 10.0;
  double _chipPadding = 5;
  double _chipPaddingExtra = 5;
  double _chipLabelHoriPadding = 10;
  double _chipLabelVertPadding = 5;
  double _chipWidth;

  @override
  Widget build(BuildContext context) {
    OriginTheme originTheme = Provider.of<OriginTheme>(context);

    ScrollController controller = ScrollController();

    bool darkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    String _originThemeId =
        getOriginThemeIdFromId(ThemeProvider.themeOf(context).id);

    _chipWidth =
        (MediaQuery.of(context).size.width - 2 * _bodyHoriPadding) / 4 -
            (2 * _chipLabelHoriPadding) -
            (2 * _chipPadding) -
            8;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _bodyHoriPadding,
        vertical: _bodyVertPadding,
      ),
      child: Column(
        children: <Widget>[
          // Switch: Dark mode
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Dark mode',
                style: TextStyle(fontSize: 15.0),
              ),
              Switch(
                activeColor: Theme.of(context).accentColor,
                onChanged: (bool isDark) {
                  if (isDark) {
                    ThemeProvider.controllerOf(context)
                        .setTheme(_originThemeId + '_dark');
                  } else {
                    ThemeProvider.controllerOf(context)
                        .setTheme(_originThemeId);
                  }

                  setState(() {
                    darkMode = isDark;
                  });
                },
                value: darkMode,
              ),
            ],
          ),

          SizedBox(height: 10.0),

          // Chip: Selected theme
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Theme color',
                style: TextStyle(fontSize: 15.0),
              ),
              Padding(
                padding: EdgeInsets.all(_chipPadding + _chipPaddingExtra),
                child: Chip(
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: _chipLabelHoriPadding,
                    vertical: _chipLabelVertPadding,
                  ),
                  backgroundColor: originTheme.primaryColor,
                  elevation: 3.0,
                  label: Container(
                    width: _chipWidth,
                    child: Text(''),
                  ),
                ),
              )
            ],
          ),

          // ActionChips: Theme options
          Container(
            height: 70.0,
            child: FadingEdgeScrollView.fromScrollView(
              gradientFractionOnStart: 0.05,
              gradientFractionOnEnd: 0.05,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: controller,
                itemCount: myAppThemes.length,
                itemBuilder: (BuildContext context, int index) {
                  return Visibility(
                    child: Padding(
                      padding: EdgeInsets.all(_chipPadding + _chipPaddingExtra),
                      child: ActionChip(
                        backgroundColor: myAppThemes[index].data.primaryColor,
                        elevation: 3.0,
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: _chipLabelHoriPadding,
                          vertical: _chipLabelVertPadding,
                        ),
                        label: Container(
                          width: _chipWidth,
                          child: Text(''),
                        ),
                        onPressed: () {
                          _originThemeId = myAppThemes[index].id;

                          if (darkMode) {
                            ThemeProvider.controllerOf(context)
                                .setTheme(_originThemeId + '_dark');
                          } else {
                            ThemeProvider.controllerOf(context)
                                .setTheme(_originThemeId);
                          }

                          setState(() {
                            _themePressed =
                                List.generate(myAppThemes.length, (i) => false);
                            _themePressed[index] = true;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
