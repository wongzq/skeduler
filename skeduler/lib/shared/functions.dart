import 'dart:io';

import 'package:flutter/material.dart';
import 'package:skeduler/models/my_app_themes.dart';
import 'package:theme_provider/theme_provider.dart';

void unfocus() {
  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
}

String getColorStr(Color color) {
  int index = myAppThemes.indexWhere((AppTheme theme) {
    return theme.data.primaryColorDark == color ||
        theme.data.primaryColor == color ||
        theme.data.accentColor == color ||
        theme.data.primaryColorLight == color;
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

Color getColorFromStrInt(String colorStr, int colorInt) {
  int index = getNativeThemeIndex(colorStr);
  if (colorInt == 0) {
    return myAppThemes[index].data.primaryColorDark;
  } else if (colorInt == 1) {
    return myAppThemes[index].data.primaryColor;
  } else if (colorInt == 2) {
    return myAppThemes[index].data.accentColor;
  } else if (colorInt == 3) {
    return myAppThemes[index].data.primaryColorLight;
  } else {
    return null;
  }
}

int getNativeThemeIndex(String themeId) {
  themeId = getNativeThemeId(themeId);

  int index = myAppThemes.indexWhere((AppTheme theme) {
    return theme.id == themeId;
  });

  return index;
}

String getNativeThemeId(String themeId) {
  int _indexOfDark = themeId.lastIndexOf('_dark');
  return _indexOfDark != -1 ? themeId.substring(0, _indexOfDark) : themeId;
}

ThemeData getNativeThemeData(String _colorId,
    {BuildContext defaultThemeOfContext}) {
  int i = myAppThemes.indexWhere((theme) => theme.id == _colorId);

  if (i != -1) {
    return myAppThemes[i].data;
  } else if (defaultThemeOfContext != null) {
    int j = myAppThemes.indexWhere((theme) =>
        theme.id ==
        getNativeThemeId(ThemeProvider.themeOf(defaultThemeOfContext).id));
    return myAppThemes[j].data;
  } else {
    return myAppThemes[0].data;
  }
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
