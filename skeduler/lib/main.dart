import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/screens/wrapper.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/models/theme_changer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ChangeNotifierProvider<ThemeChanger>(
      create: (_) => ThemeChanger(),
      child: StreamProvider<User>.value(
        value: AuthService().user,
        child: MaterialAppWithTheme(),
      ),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      title: 'Skeduler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: theme.primarySwatch,
        accentColor: theme.accentColor,
        brightness: theme.brightness,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: InkRipple.splashFactory,
      ),
      home: Wrapper(),
    );
  }
}
