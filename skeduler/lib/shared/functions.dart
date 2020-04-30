import 'dart:io';

import 'package:flutter/material.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/auxiliary/my_app_themes.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/group_data/member.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/models/group_data/timetable.dart';
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
      ? Theme.of(context).primaryTextTheme.title.color
      : Theme.of(context).primaryTextTheme.title.color;
}

Color getFABIconForegroundColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? Theme.of(context).primaryIconTheme.color
      : Theme.of(context).primaryIconTheme.color;
}

Color getFABIconBackgroundColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? getOriginThemeData(ThemeProvider.themeOf(context).id).primaryColor
      : getOriginThemeData(ThemeProvider.themeOf(context).id).primaryColorDark;
}

bool memberIsAvailable(
  List<Member> members,
  TimetableDragData dragData,
  TimetableGridData gridData,
  EditTimetable timetable,
) {
  Member memberFound;

  bool isAvailable = false;

  if (dragData is TimetableDragMember) {
    members.forEach((member) {
      if (member.display == dragData.display) {
        memberFound = member;
      }
    });
  } else if (dragData is TimetableDragSubjectMember) {
    members.forEach((member) {
      if (member.display == dragData.member.display) {
        memberFound = member;
      }
    });
  }

  if (memberFound != null) {
    // for each day within timetable range
    for (int i = 0;
        i <
            timetable.endDate
                .add(Duration(days: 1))
                .difference(timetable.startDate)
                .inDays;
        i++) {
      DateTime ttbDate = timetable.startDate.add(Duration(days: i));

      DateTime gridStartTime = DateTime(
        ttbDate.year,
        ttbDate.month,
        ttbDate.day,
        gridData.coord.time.startTime.hour,
        gridData.coord.time.startTime.minute,
      );

      DateTime gridEndTime = DateTime(
        ttbDate.year,
        ttbDate.month,
        ttbDate.day,
        gridData.coord.time.endTime.hour,
        gridData.coord.time.endTime.minute,
      );

      // if day matches
      if (Weekday.values[ttbDate.weekday - 1] == gridData.coord.day) {
        // iterate through each time
        memberFound.times.forEach((time) {
          if ((time.startTime.isBefore(gridStartTime) ||
                  time.startTime.isAtSameMomentAs(gridStartTime)) &&
              (time.endTime.isAtSameMomentAs(gridEndTime) ||
                  time.endTime.isAfter(gridEndTime))) {
            isAvailable = true;
          }
        });
      }
    }
  }
  print(isAvailable);
  return isAvailable;
}
