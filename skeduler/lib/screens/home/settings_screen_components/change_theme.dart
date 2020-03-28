import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/my_app_themes.dart';
import 'package:skeduler/models/native_theme.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:theme_provider/theme_provider.dart';

class ChangeTheme extends StatefulWidget {
  @override
  _ChangeThemeState createState() => _ChangeThemeState();
}

class _ChangeThemeState extends State<ChangeTheme> {
  List<bool> _themePressed = List.generate(myAppThemes.length, (i) => false);
  double _bodyPadding = 20.0;
  double _chipPadding = 5;
  double _chipPaddingExtra = 5;
  double _chipLabelHoriPadding = 10;
  double _chipLabelVertPadding = 5;
  double _chipWidth;

  @override
  Widget build(BuildContext context) {
    NativeTheme _nativeTheme = Provider.of<NativeTheme>(context);

    final _controller = ScrollController();

    bool _darkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    String _nativeThemeId =
        getNativeThemeId(ThemeProvider.themeOf(context).id);

    _chipWidth = (MediaQuery.of(context).size.width - 2 * _bodyPadding) / 4 -
        (2 * _chipLabelHoriPadding) -
        (2 * _chipPadding) -
        8;

    return Container(
      padding: EdgeInsets.all(_bodyPadding),
      height: 600,
      child: Column(
        children: <Widget>[
          // Switch: Dark mode
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Dark mode'),
              Switch(
                activeColor: Theme.of(context).accentColor,
                onChanged: (bool isDark) {
                  if (isDark) {
                    ThemeProvider.controllerOf(context)
                        .setTheme(_nativeThemeId + '_dark');
                  } else {
                    ThemeProvider.controllerOf(context)
                        .setTheme(_nativeThemeId);
                  }

                  setState(() {
                    _darkMode = isDark;
                  });
                },
                value: _darkMode,
              ),
            ],
          ),

          SizedBox(height: 20.0),

          // Chip: Selected theme
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Theme colour'),
              Padding(
                padding: EdgeInsets.all(_chipPadding + _chipPaddingExtra),
                child: Chip(
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: _chipLabelHoriPadding,
                    vertical: _chipLabelVertPadding,
                  ),
                  backgroundColor: _nativeTheme.primaryColor,
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
                controller: _controller,
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
                          _nativeThemeId = myAppThemes[index].id;

                          if (_darkMode) {
                            ThemeProvider.controllerOf(context)
                                .setTheme(_nativeThemeId + '_dark');
                          } else {
                            ThemeProvider.controllerOf(context)
                                .setTheme(_nativeThemeId);
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
