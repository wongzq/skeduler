import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:skeduler/models/my_app_themes.dart';
import 'package:theme_provider/theme_provider.dart';

class ChangeTheme extends StatefulWidget {
  @override
  _ChangeThemeState createState() => _ChangeThemeState();
}

class _ChangeThemeState extends State<ChangeTheme> {
  final _controller = ScrollController();
  List<bool> _themePressed = List.generate(myAppThemes.length, (i) => false);

  @override
  Widget build(BuildContext context) {
    bool _darkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    String _themeId = ThemeProvider.themeOf(context).id;
    int _indexOfDark = _themeId.lastIndexOf('_dark');
    String _nativeThemeId =
        _indexOfDark != -1 ? _themeId.substring(0, _indexOfDark) : _themeId;

    return Container(
      padding: const EdgeInsets.all(20.0),
      height: 400,
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

          Expanded(
            child: FadingEdgeScrollView.fromScrollView(
              gradientFractionOnStart: 0.1,
              gradientFractionOnEnd: 0.1,
              child: ListView.builder(
                controller: _controller,
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                itemCount: myAppThemes.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 5.0,
                      horizontal: _themePressed[index] ? 5.0 : 25.0,
                    ),
                    child: GestureDetector(
                      onTap: () {
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
                      child: Container(
                        alignment: Alignment.center,
                        height: _themePressed[index] ? 60.0 : 50.0,
                        decoration: BoxDecoration(
                          color: _themePressed[index]
                              ? myAppThemes[index].data.primaryColor
                              : myAppThemes[index].data.primaryColor,
                          borderRadius: BorderRadius.circular(
                              _themePressed[index] ? 12.0 : 10.0),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2.0,
                              offset: Offset(0.0, 2.0),
                            )
                          ],
                        ),
                        child: Text(
                          myAppThemes[index].description,
                          style: TextStyle(
                            shadows: [
                              Shadow(blurRadius: 2.0, offset: Offset(0.0, 1.0))
                            ],
                            color: Colors.white,
                            fontSize: _themePressed[index] ? 20.0 : 16.0,
                            fontWeight: _themePressed[index]
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
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
