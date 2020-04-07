import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/auxiliary/my_app_themes.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/models/group_data/user.dart';
import 'package:skeduler/models/auxiliary/native_theme.dart';
import 'package:skeduler/route_generator.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:theme_provider/theme_provider.dart';

void main() => runApp(MyApp());

class MyApp2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Month> months = [Month.jan, Month.feb];
    List<WeekDay> days = [WeekDay.mon, WeekDay.wed];
    Time time = Time(
      DateTime(2020, 1, 1, 15, 00),
      DateTime(2020, 1, 1, 18, 00),
    );

    List<Time> times = generateTimes(
      months: months,
      weekDays: days,
      time: time,
      startDate: DateTime(2020, 2, 8),
      endDate: DateTime(2020, 2, 30),
    );

    DatabaseService dbService =
        DatabaseService(userId: 'wong.zhengquan@gmail.com');
    dbService.modifyGroupMemberTimes(
        'KLlU4B609GMb2JfVzroN', 'wong.zhengquan@gmail.com', times);

    return MaterialApp(
      home: Scaffold(
        body: Text(''),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  /// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    DatabaseService dbService;
    OriginTheme originTheme = OriginTheme();

    return RestartWidget(
      child: ThemeProvider(
        themes: myAppThemes + myAppDarkThemes,
        defaultThemeId: 'teal',
        loadThemeOnInit: true,
        saveThemesOnChange: true,
        onThemeChanged: (AppTheme oldTheme, AppTheme newTheme) {
          int themeIndex;
          bool themeDarkMode =
              newTheme.data.brightness == Brightness.dark ? true : false;

          if (themeDarkMode) {
            themeIndex = myAppDarkThemes
                .indexWhere((AppTheme theme) => theme.id == newTheme.id);
          } else {
            themeIndex = myAppThemes
                .indexWhere((AppTheme theme) => theme.id == newTheme.id);
          }

          originTheme.primaryColor = myAppThemes[themeIndex].data.primaryColor;
          originTheme.primaryColorLight =
              myAppThemes[themeIndex].data.primaryColorLight;
          originTheme.primaryColorDark =
              myAppThemes[themeIndex].data.primaryColorDark;
          originTheme.accentColor = myAppThemes[themeIndex].data.accentColor;
        },
        child: ThemeConsumer(
          child: Builder(
            builder: (themeContext) {
              int themeIndex;
              bool themeDarkMode =
                  ThemeProvider.themeOf(themeContext).data.brightness ==
                          Brightness.dark
                      ? true
                      : false;

              if (themeDarkMode) {
                themeIndex = myAppDarkThemes.indexWhere((AppTheme theme) =>
                    theme.id == ThemeProvider.themeOf(themeContext).id);
              } else {
                themeIndex = myAppThemes.indexWhere((AppTheme theme) =>
                    theme.id == ThemeProvider.themeOf(themeContext).id);
              }

              originTheme.primaryColor =
                  myAppThemes[themeIndex].data.primaryColor;
              originTheme.primaryColorLight =
                  myAppThemes[themeIndex].data.primaryColorLight;
              originTheme.primaryColorDark =
                  myAppThemes[themeIndex].data.primaryColorDark;
              originTheme.accentColor =
                  myAppThemes[themeIndex].data.accentColor;

              /// Provide User from Firebase
              return StreamProvider<AuthUser>.value(
                value: AuthService().user,
                child: Consumer<AuthUser>(
                  builder: (_, user, __) {
                    dbService =
                        DatabaseService(userId: user != null ? user.email : '');

                    /// Multiple Providers
                    return MultiProvider(
                      providers: [
                        ChangeNotifierProvider<OriginTheme>.value(
                          value: originTheme,
                        ),
                        Provider<DatabaseService>.value(
                          value: dbService,
                        ),
                        StreamProvider<User>.value(
                          value: dbService.user,
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
                        theme:
                            ThemeProvider.themeOf(themeContext).data.copyWith(
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
      ),
    );
  }
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  RestartWidget({this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>().restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
