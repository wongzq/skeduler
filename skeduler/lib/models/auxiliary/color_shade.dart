import 'package:flutter/material.dart';
import 'package:skeduler/models/auxiliary/my_app_themes.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:theme_provider/theme_provider.dart';

enum Shade {
  primaryColorDark,
  primaryColor,
  accentColor,
  primaryColorLight,
  none,
}

class ColorShade {
  // properties
  Color _color;
  String _themeId;
  Shade _shade;

  // constructors
  ColorShade({
    Color color,
    String themeId,
    Shade shade,
  }) {
    // use [Color] to set the values for [String] and [Shade]
    if (color != null && themeId == null && shade == null) {
      _setWithColor(color);
    }

    // use [String] and [Shade] to set the value for [Color]
    else if (color == null && themeId != null) {
      _setWithThemeIdAndShade(themeId, shade);
    }
  }

  // getter methods
  Color get color => this._color;
  String get themeId => this._themeId;
  Shade get shade => this._shade;
  int get shadeIndex => this._shade.index;

  // setter methods
  set color(Color color) => _setWithColor(color);
  set themeId(String themeId) => _setWithThemeIdAndShade(themeId, this._shade);
  set shade(Shade shade) => _setWithThemeIdAndShade(this._themeId, shade);

  // auxiliary methods
  bool _setWithColor(Color color) {
    if (themeIdFromColor(color) != null && themeIdFromColor(color) != '') {
      this._color = color;
      this._themeId = themeIdFromColor(color);
      this._shade = shadeFromColor(color);

      return true;
    } else {
      return false;
    }
  }

  bool _setWithThemeIdAndShade(String themeId, Shade shade) {
    int index = myAppThemes.indexWhere((theme) => theme.id == themeId);

    if (index != -1) {
      shade = shade ?? Shade.primaryColor;

      this._color = colorFromThemeIdAndShade(themeId, shade);
      this._themeId = themeId;
      this._shade = shade;

      return true;
    } else {
      return false;
    }
  }

  // static methods
  static String themeIdFromColor(Color color) {
    int index = myAppThemes.indexWhere((AppTheme theme) {
      return theme.data.primaryColor == color ||
          theme.data.primaryColorDark == color ||
          theme.data.primaryColorLight == color ||
          theme.data.accentColor == color;
    });

    return index != -1 ? myAppThemes[index].id : '';
  }

  static Shade shadeFromColor(Color color) {
    Shade shade = Shade.none;
    myAppThemes.forEach((theme) {
      if (theme.data.primaryColorDark == color) {
        shade = Shade.primaryColorDark;
      } else if (theme.data.primaryColor == color) {
        shade = Shade.primaryColor;
      } else if (theme.data.accentColor == color) {
        shade = Shade.accentColor;
      } else if (theme.data.primaryColorLight == color) {
        shade = Shade.primaryColorLight;
      }
    });

    return shade;
  }

  static Color colorFromThemeIdAndShade(String themeId, Shade colorType) {
    int index = getOriginThemeIndexFromId(themeId);

    if (index != -1) {
      switch (colorType) {
        case Shade.primaryColorDark:
          return myAppThemes[index].data.primaryColorDark;
          break;
        case Shade.primaryColor:
          return myAppThemes[index].data.primaryColor;
          break;
        case Shade.accentColor:
          return myAppThemes[index].data.accentColor;
          break;
        case Shade.primaryColorLight:
          return myAppThemes[index].data.primaryColorLight;
          break;
        default:
          return myAppThemes[index].data.primaryColor;
      }
    } else {
      return null;
    }
  }
}
