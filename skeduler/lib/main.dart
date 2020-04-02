import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/drawer_enum.dart';
import 'package:skeduler/models/my_app_themes.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/models/native_theme.dart';
import 'package:skeduler/route_generator.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:theme_provider/theme_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  /// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    DatabaseService _dbService;
    NativeTheme _nativeTheme = NativeTheme();

    return ThemeProvider(
      themes: myAppThemes + myAppDarkThemes,
      defaultThemeId: 'teal',
      loadThemeOnInit: true,
      saveThemesOnChange: true,
      onThemeChanged: (AppTheme oldTheme, AppTheme newTheme) {
        int _themeIndex;
        bool _themeDarkMode =
            newTheme.data.brightness == Brightness.dark ? true : false;

        if (_themeDarkMode) {
          _themeIndex = myAppDarkThemes
              .indexWhere((AppTheme theme) => theme.id == newTheme.id);
        } else {
          _themeIndex = myAppThemes
              .indexWhere((AppTheme theme) => theme.id == newTheme.id);
        }

        _nativeTheme.primaryColor = myAppThemes[_themeIndex].data.primaryColor;
        _nativeTheme.primaryColorLight =
            myAppThemes[_themeIndex].data.primaryColorLight;
        _nativeTheme.primaryColorDark =
            myAppThemes[_themeIndex].data.primaryColorDark;
        _nativeTheme.accentColor = myAppThemes[_themeIndex].data.accentColor;
      },
      child: ThemeConsumer(
        child: Builder(
          builder: (themeContext) {
            int _themeIndex;
            bool _themeDarkMode =
                ThemeProvider.themeOf(themeContext).data.brightness ==
                        Brightness.dark
                    ? true
                    : false;

            if (_themeDarkMode) {
              _themeIndex = myAppDarkThemes.indexWhere((AppTheme theme) =>
                  theme.id == ThemeProvider.themeOf(themeContext).id);
            } else {
              _themeIndex = myAppThemes.indexWhere((AppTheme theme) =>
                  theme.id == ThemeProvider.themeOf(themeContext).id);
            }

            _nativeTheme.primaryColor =
                myAppThemes[_themeIndex].data.primaryColor;
            _nativeTheme.primaryColorLight =
                myAppThemes[_themeIndex].data.primaryColorLight;
            _nativeTheme.primaryColorDark =
                myAppThemes[_themeIndex].data.primaryColorDark;
            _nativeTheme.accentColor =
                myAppThemes[_themeIndex].data.accentColor;

            /// Provide User from Firebase
            return StreamProvider<AuthUser>.value(
              value: AuthService().user,
              child: Consumer<AuthUser>(
                builder: (_, user, __) {
                  _dbService =
                      DatabaseService(uid: user != null ? user.uid : '');

                  /// Multiple Providers
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider<NativeTheme>.value(
                        value: _nativeTheme,
                      ),
                      Provider<DatabaseService>.value(
                        value: _dbService,
                      ),
                      StreamProvider<User>.value(
                        value: _dbService.user,
                      ),

                      /// Current Drawer Selected
                      ChangeNotifierProvider<ValueNotifier<DrawerEnum>>(
                        create: (_) =>
                            ValueNotifier<DrawerEnum>(DrawerEnum.dashboard),
                      ),

                      /// Group Doc ID
                      ChangeNotifierProvider<ValueNotifier<String>>(
                        create: (_) => ValueNotifier<String>(''),
                      )
                    ],
                    child: MaterialApp(
                      title: 'Skeduler',
                      debugShowCheckedModeBanner: false,
                      theme: ThemeProvider.themeOf(themeContext).data.copyWith(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashFactory: InkRipple.splashFactory,
                          ),
                      initialRoute: '/dashboard',
                      onGenerateRoute: RouteGenerator.generateRoute,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
