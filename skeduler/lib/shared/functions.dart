import 'dart:io';

import 'package:flutter/material.dart';
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

String getColorStr(Color color) {
  int index = myAppThemes.indexWhere((AppTheme theme) {
    return theme.data.primaryColor == color ||
        theme.data.primaryColorDark == color ||
        theme.data.primaryColorLight == color ||
        theme.data.accentColor == color;
  });

  return index != -1 ? myAppThemes[index].id : '';
}

int getColorInt(Color color) {
  int colorInt = -1;

  myAppThemes.forEach((theme) {
    if (theme.data.primaryColorDark == color) {
      colorInt = 0;
    } else if (theme.data.primaryColor == color) {
      colorInt = 1;
    } else if (theme.data.accentColor == color) {
      colorInt = 2;
    } else if (theme.data.primaryColorLight == color) {
      colorInt = 3;
    }
  });

  return colorInt;
}

Color getColorFromStrInt(String colorStr, {int colorInt = 1}) {
  int index = getNativeThemeIndexFromId(colorStr);

  if (index >= 0 && index < myAppThemes.length) {
    if (colorInt == 0) {
      return myAppThemes[index].data.primaryColorDark;
    } else if (colorInt == 1) {
      return myAppThemes[index].data.primaryColor;
    } else if (colorInt == 2) {
      return myAppThemes[index].data.accentColor;
    } else if (colorInt == 3) {
      return myAppThemes[index].data.primaryColorLight;
    } else {
      return myAppThemes[index].data.primaryColor;
    }
  } else {
    return null;
  }
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

ThemeData getNativeThemeData(
  String _colorId, {
  BuildContext defaultThemeOfContext,
}) {
  int i = myAppThemes.indexWhere((theme) => theme.id == _colorId);

  if (i != -1) {
    return myAppThemes[i].data;
  } else if (defaultThemeOfContext != null) {
    int j = myAppThemes.indexWhere((theme) =>
        theme.id ==
        getNativeThemeIdFromId(
            ThemeProvider.themeOf(defaultThemeOfContext).id));
    return myAppThemes[j].data;
  } else {
    return myAppThemes[0].data;
  }
}
