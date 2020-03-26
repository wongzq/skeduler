import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/MyAppTheme.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/screens/wrapper.dart';
import 'package:skeduler/services/auth_service.dart';
import 'package:skeduler/models/theme_changer.dart';
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
      themes: appThemes,
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
    return MaterialApp(
      title: 'Skeduler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: InkRipple.splashFactory,
      ),
      home: ThemeConsumer(
        child: Wrapper(),
      ),
    );
  }
}
