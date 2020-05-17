import 'package:flutter/material.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:theme_provider/theme_provider.dart';

class AppBarTitle extends StatelessWidget {
  final String title;
  final String alternateTitle;
  final String subtitle;

  AppBarTitle({
    @required this.title,
    this.alternateTitle,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return this.subtitle == null
        ? Text(
            title ?? alternateTitle ?? '',
            style: textStyleAppBarTitle,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title ?? alternateTitle ?? '',
                style: textStyleAppBarTitle,
              ),
              Text(
                subtitle ?? '',
                style: textStyleBody,
              ),
            ],
          );
  }
}

class LoadingSnackBar extends SnackBar {
  LoadingSnackBar(
    BuildContext context,
    String message,
  ) : super(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Row(
            children: <Widget>[
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  getOriginThemeData(
                    ThemeProvider.themeOf(context).id,
                  ).accentColor,
                ),
              ),
              SizedBox(width: 20.0),
              Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).primaryTextTheme.bodyText1.color,
                ),
              ),
            ],
          ),
        );
}
