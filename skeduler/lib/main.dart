import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/my_app_themes.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/screens/wrapper.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:theme_provider/theme_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ThemeProvider(
      themes: myAppThemes + myAppDarkThemes,
      defaultThemeId: 'teal',
      loadThemeOnInit: true,
      saveThemesOnChange: true,
      child: ThemeConsumer(
        child: Builder(
          builder: (themeContext) {
            return StreamProvider<User>.value(
              value: AuthService().user,
              child: MaterialApp(
                title: 'Skeduler',
                debugShowCheckedModeBanner: false,
                theme: ThemeProvider.themeOf(themeContext).data.copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashFactory: InkRipple.splashFactory,
                    ),
                home: Wrapper(),
              ),
            );
          },
        ),
      ),
    );
  }
}
