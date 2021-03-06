import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeduler/models/auxiliary/my_app_themes.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/auxiliary/preferences.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/models/firestore/subject.dart';
import 'package:skeduler/models/firestore/timetable.dart';
import 'package:skeduler/models/firestore/user.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/navigation/route_generator.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:theme_provider/theme_provider.dart';

void main() => runApp(SkedulerApp ());

class SkedulerApp extends StatelessWidget {
  final OriginTheme originTheme = OriginTheme();
  final GroupStatus groupStatus = GroupStatus();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    DatabaseService dbService;

    return RestartWidget(
      child: FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, preferencesSnap) {
            return ThemeProvider(
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

                originTheme.primaryColor =
                    myAppThemes[themeIndex].data.primaryColor;
                originTheme.primaryColorLight =
                    myAppThemes[themeIndex].data.primaryColorLight;
                originTheme.primaryColorDark =
                    myAppThemes[themeIndex].data.primaryColorDark;
                originTheme.accentColor =
                    myAppThemes[themeIndex].data.accentColor;
                originTheme.textColor = myAppThemes[themeIndex]
                    .data
                    .primaryTextTheme
                    .bodyText1
                    .color;
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
                      themeIndex = myAppDarkThemes.indexWhere(
                          (AppTheme theme) =>
                              theme.id ==
                              ThemeProvider.themeOf(themeContext).id);
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
                    originTheme.textColor = myAppThemes[themeIndex]
                        .data
                        .primaryTextTheme
                        .bodyText1
                        .color;

                    // Provide User from Firebase
                    return StreamProvider<AuthUser>.value(
                      value: AuthService().user,
                      child: Consumer<AuthUser>(
                        builder: (_, user, __) {
                          dbService = DatabaseService(
                              userId: user != null ? user.email : '');

                          // Multiple Providers
                          return MultiProvider(
                            providers: [
                              ChangeNotifierProvider<Preferences>(
                                create: (_) => Preferences(
                                  preferencesSnap.data,
                                ),
                              ),
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
                                return _generateMaterialAppWithGroupStatusProvider(
                                    dbService, themeContext);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          }),
    );
  }

  Widget _generateMaterialAppWithGroupStatusProvider(
      DatabaseService dbService, BuildContext themeContext) {
    return Consumer<ValueNotifier<String>>(builder: (_, groupDocId, __) {
      // stream Group
      return StreamBuilder<Group>(
          stream: dbService.streamGroup(groupDocId.value),
          builder: (_, groupSnap) {
            // stream Group Members
            return StreamBuilder<List<Member>>(
                stream: dbService.streamGroupMembers(groupDocId.value),
                builder: (_, membersSnap) {
                  // stream Group Subjects
                  return StreamBuilder<List<Subject>>(
                      stream: dbService.streamGroupSubjects(groupDocId.value),
                      builder: (_, subjectsSnap) {
                        // stream Group Timetables
                        return StreamBuilder<List<Timetable>>(
                            stream: dbService
                                .streamGroupTimetables(groupDocId.value),
                            builder: (_, timetablesSnap) {
                              return StreamBuilder<Member>(
                                  stream: dbService
                                      .streamGroupMemberMe(groupDocId.value),
                                  builder: (_, meSnap) {
                                    groupStatus.update(
                                        newGroup: groupDocId.value != null
                                            ? groupSnap != null
                                                ? groupSnap.data
                                                : null
                                            : null,
                                        newMembers: groupDocId.value != null
                                            ? membersSnap != null
                                                ? membersSnap.data
                                                : null
                                            : null,
                                        newSubjects: groupDocId.value != null
                                            ? subjectsSnap != null
                                                ? subjectsSnap.data
                                                : null
                                            : null,
                                        newTimetables: groupDocId.value != null
                                            ? timetablesSnap != null
                                                ? timetablesSnap.data
                                                : null
                                            : null,
                                        newMe: groupDocId.value != null
                                            ? meSnap != null
                                                ? meSnap.data
                                                : null
                                            : null);

                                    // Provider for GroupStatus
                                    return ChangeNotifierProvider<
                                            GroupStatus>.value(
                                        value: groupStatus,
                                        child: MaterialApp(
                                            title: 'Skeduler',
                                            debugShowCheckedModeBanner: false,
                                            theme: ThemeProvider.themeOf(
                                                    themeContext)
                                                .data
                                                .copyWith(
                                                    splashColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    splashFactory: InkRipple
                                                        .splashFactory),
                                            initialRoute: '/dashboard',
                                            onGenerateRoute:
                                                RouteGenerator.generateRoute));
                                  });
                            });
                      });
                });
          });
    });
  }
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  RestartWidget({@required this.child});

  static void restartApp(BuildContext context) =>
      context.findAncestorStateOfType<_RestartWidgetState>().restartApp();

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() => setState(() => key = UniqueKey());

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: key, child: widget.child);
}
