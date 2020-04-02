import 'dart:io';

import 'package:flutter/material.dart';
import 'package:skeduler/models/color_shade.dart';
import 'package:skeduler/models/my_app_themes.dart';
import 'package:theme_provider/theme_provider.dart';

void unfocus() {
  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
}

Future<bool> checkInternetConnection() async {
  bool hasConn;
  hasConn = await InternetAddress.lookup('google.com')
      .then((result) {
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        } else {
          return false;
        }
      })
      .timeout(Duration(seconds: 5))
      .catchError((_) {
        return false;
      });
  return hasConn;
}

int getNativeThemeIndexFromColor(Color color) {
  int index = myAppThemes.indexWhere((AppTheme theme) {
    return theme.data.primaryColor == color ||
        theme.data.primaryColorDark == color ||
        theme.data.primaryColorLight == color ||
        theme.data.accentColor == color;
  });

  return index;
}

int getNativeThemeIndexFromId(String themeId) {
  themeId = getNativeThemeIdFromId(themeId);

  int index = myAppThemes.indexWhere((AppTheme theme) {
    return theme.id == themeId;
  });

  return index;
}

String getNativeThemeIdFromId(String themeId) {
  int _indexOfDark = themeId.lastIndexOf('_dark');
  return _indexOfDark != -1 ? themeId.substring(0, _indexOfDark) : themeId;
}

ThemeData getNativeThemeData(String themeId) {
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

Color getNativeThemeColorShade(ColorShade colorShade) {
  ThemeData theme = getNativeThemeData(colorShade.themeId);

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
