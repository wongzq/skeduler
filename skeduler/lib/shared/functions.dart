import 'dart:io';

import 'package:flutter/material.dart';
import 'package:skeduler/models/my_app_themes.dart';
import 'package:theme_provider/theme_provider.dart';

void unfocus() {
  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
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
