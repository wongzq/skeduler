import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/my_app_themes.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/user.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/route_generator.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/services/database_service.dart';
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

              // Provide User from Firebase
              return StreamProvider<AuthUser>.value(
                value: AuthService().user,
                child: Consumer<AuthUser>(
                  builder: (_, user, __) {
                    dbService =
                        DatabaseService(userId: user != null ? user.email : '');

                    // Multiple Providers
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

                        // Group Doc ID
                        ChangeNotifierProvider<ValueNotifier<String>>(
                          create: (_) => ValueNotifier<String>(''),
                        ),

                        // TimetableStatus
                        ChangeNotifierProvider<TimetableStatus>(
                          create: (_) => TimetableStatus(),
                        ),
                      ],
                      child: Consumer<DatabaseService>(
                        builder: (_, dbService, __) {
                          return Consumer<ValueNotifier<String>>(
                            builder: (_, groupDocId, __) {
                              return StreamBuilder(
                                  stream: dbService.streamGroup(groupDocId.value),
                                  builder: (_, snapshot) {
                                    return ChangeNotifierProvider<
                                        GroupStatus>.value(
                                      value: GroupStatus(
                                        group: snapshot != null
                                            ? snapshot.data
                                            : null,
                                      ),
                                      child: MaterialApp(
                                        title: 'Skeduler',
                                        debugShowCheckedModeBanner: false,
                                        theme:
                                            ThemeProvider.themeOf(themeContext)
                                                .data
                                                .copyWith(
                                                  splashColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  splashFactory:
                                                      InkRipple.splashFactory,
                                                ),
                                        initialRoute: '/dashboard',
                                        onGenerateRoute:
                                            RouteGenerator.generateRoute,
                                      ),
                                    );
                                  });
                            },
                          );
                        },
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
