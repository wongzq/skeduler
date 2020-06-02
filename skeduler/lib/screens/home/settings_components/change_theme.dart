import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/my_app_themes.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:theme_provider/theme_provider.dart';

class ChangeTheme extends StatefulWidget {
  @override
  _ChangeThemeState createState() => _ChangeThemeState();
}

class _ChangeThemeState extends State<ChangeTheme> {
  final double _bodyHoriPadding = 20.0;
  final double _chipInterPadding = 5;
  final double _chipInterPaddingExtra = 5;
  final double _chipIntraPadding = 3;
  double _chipWidth;

  List<bool> _themePressed = List.generate(myAppThemes.length, (i) => false);

  @override
  Widget build(BuildContext context) {
    ScrollController controller = ScrollController();
    OriginTheme originTheme = Provider.of<OriginTheme>(context);

    bool darkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    String _originThemeId =
        getOriginThemeIdFromId(ThemeProvider.themeOf(context).id);

    _chipWidth =
        (MediaQuery.of(context).size.width - 2 * _bodyHoriPadding) / 4 -
            (2 * _chipInterPadding) -
            8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Switch: Dark mode
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _bodyHoriPadding),
          child: Row(
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
        ),

        // Chip: Selected theme
        Padding(
          padding: EdgeInsets.all(4.0),
          child: Theme(
            data: Theme.of(context).copyWith(
              accentColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              onExpansionChanged: (val) {
                setState(() {
                  controller = ScrollController();
                });
              },
              title: Text(
                'Theme color',
                style: TextStyle(fontSize: 15.0),
              ),
              trailing: Padding(
                padding: EdgeInsets.all(_chipInterPadding),
                child: Chip(
                  labelPadding: EdgeInsets.symmetric(
                    vertical: _chipIntraPadding,
                  ),
                  backgroundColor: originTheme.primaryColor,
                  elevation: 3.0,
                  label: Container(
                    width: _chipWidth,
                    child: Text(''),
                  ),
                ),
              ),
              children: <Widget>[
                // ActionChips: Theme options
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
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
                              padding: EdgeInsets.all(
                                _chipInterPadding + _chipInterPaddingExtra,
                              ),
                              child: ActionChip(
                                backgroundColor:
                                    myAppThemes[index].data.primaryColor,
                                elevation: 3.0,
                                labelPadding: EdgeInsets.symmetric(
                                  vertical: _chipIntraPadding,
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
                                    _themePressed = List.generate(
                                        myAppThemes.length, (i) => false);
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
