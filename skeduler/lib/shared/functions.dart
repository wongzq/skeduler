import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quiver/time.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/auxiliary/my_app_themes.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:theme_provider/theme_provider.dart';

void unfocus() {
  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
}

Future<bool> checkInternetConnection() async {
  return await InternetAddress.lookup('google.com')
      .then((result) =>
          result.isNotEmpty && result[0].rawAddress.isNotEmpty ? true : false)
      .timeout(Duration(seconds: 5), onTimeout: () => false)
      .catchError((_) => false);
}

int getOriginThemeIndexFromColor(Color color) {
  int index = myAppThemes.indexWhere((AppTheme theme) {
    return theme.data.primaryColor == color ||
        theme.data.primaryColorDark == color ||
        theme.data.primaryColorLight == color ||
        theme.data.accentColor == color;
  });

  return index;
}

int getOriginThemeIndexFromId(String themeId) {
  themeId = getOriginThemeIdFromId(themeId);

  int index = myAppThemes.indexWhere((AppTheme theme) {
    return theme.id == themeId;
  });

  return index;
}

String getOriginThemeIdFromId(String themeId) {
  int _indexOfDark = themeId.lastIndexOf('_dark');
  return _indexOfDark != -1 ? themeId.substring(0, _indexOfDark) : themeId;
}

ThemeData getOriginThemeData(String themeId) {
  int index = myAppThemes.indexWhere((theme) => theme.id == themeId);
  int darkIndex = myAppDarkThemes.indexWhere((theme) => theme.id == themeId);
  int defaultIndex = myAppThemes
      .indexWhere((theme) => theme.data.primaryColor == defaultColor);

  if (index != -1) {
    return myAppThemes[index].data;
  } else if (darkIndex != -1) {
    return myAppThemes[darkIndex].data;
  } else {
    return myAppThemes[defaultIndex].data;
  }
}

Color getColorFromColorShade(ColorShade colorShade) {
  ThemeData theme = getOriginThemeData(colorShade.themeId);

  switch (colorShade.shade) {
    case Shade.primaryColorDark:
      return theme.primaryColorDark;
      break;
    case Shade.primaryColor:
      return theme.primaryColor;
      break;
    case Shade.accentColor:
      return theme.accentColor;
      break;
    case Shade.primaryColorLight:
      return theme.primaryColorLight;
      break;
    case Shade.none:
      return defaultColor;
      break;
  }
  return null;
}

Color getFABTextColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? Theme.of(context).primaryTextTheme.bodyText1.color
      : Theme.of(context).primaryTextTheme.bodyText1.color;
}

Color getFABIconForegroundColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? getOriginThemeData(ThemeProvider.themeOf(context).id).primaryIconTheme.color
      : getOriginThemeData(ThemeProvider.themeOf(context).id).primaryIconTheme.color;
}

Color getFABIconBackgroundColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? getOriginThemeData(ThemeProvider.themeOf(context).id).primaryColor
      : getOriginThemeData(ThemeProvider.themeOf(context).id).primaryColorDark;
}

DateTime getFirstDayOfStartMonth(List<Month> months) {
  if (months != null && months.isNotEmpty) {
    return DateTime(
      DateTime.now().year,
      months.first.index + 1,
    );
  } else {
    return null;
  }
}

DateTime getLastDayOfLastMonth(List<Month> months) {
  if (months != null && months.isNotEmpty) {
    return DateTime(
      DateTime.now().year,
      months.last.index + 1,
      daysInMonth(
        DateTime.now().year,
        months.last.index + 1,
      ),
    );
  } else {
    return null;
  }
}
