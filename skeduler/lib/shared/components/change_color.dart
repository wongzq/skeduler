import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:skeduler/models/auxiliary/color_shade.dart';
import 'package:skeduler/models/auxiliary/my_app_themes.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:theme_provider/theme_provider.dart';

class ChangeColor extends StatefulWidget {
  /// properties
  final bool initialExpanded;
  final ColorShade initialValue;
  final ValueSetter<bool> valueSetterExpanded;
  final ValueSetter<ColorShade> valueSetterColorShade;

  /// constructor
  const ChangeColor({
    this.initialExpanded = true,
    this.initialValue,
    this.valueSetterExpanded,
    this.valueSetterColorShade,
  });

  @override
  _ChangeColorState createState() => _ChangeColorState();
}

class _ChangeColorState extends State<ChangeColor> {
  double _bodyHoriPadding = 5.0;
  double _chipPadding = 5;
  double _chipPaddingExtra = 2;
  double _chipLabelHoriPadding = 5;
  double _chipLabelVertPadding = 5;
  double _chipWidth;

  int _shades = 4;
  ColorShade _colorShade;
  bool _expanded;

  @override
  void initState() {
    _expanded = widget.initialExpanded;
    _colorShade = widget.initialValue ?? ColorShade();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _chipWidth =
        (MediaQuery.of(context).size.width - 2 * _bodyHoriPadding) / 5 -
            (2 * _chipLabelHoriPadding) -
            (2 * _chipPadding) -
            8;

    ScrollController controller = ScrollController();

    return ExpansionTile(
      initiallyExpanded: widget.initialExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          _expanded = !_expanded;
          if (widget.valueSetterExpanded != null)
            widget.valueSetterExpanded(_expanded);
        });
      },
      trailing: Icon(
        _expanded ? Icons.expand_less : Icons.expand_more,
        color:
            ThemeProvider.themeOf(context).data.brightness == Brightness.light
                ? Colors.black
                : Colors.white,
      ),
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: _bodyHoriPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Color',
              style: TextStyle(
                fontSize: 15.0,
                color: ThemeProvider.themeOf(context).data.brightness ==
                        Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(_chipPadding + _chipPaddingExtra),
              child: Chip(
                labelPadding: EdgeInsets.symmetric(
                  horizontal: _chipLabelHoriPadding,
                  vertical: _chipLabelVertPadding,
                ),
                backgroundColor: () {
                  if (_colorShade.color == null) {
                    _colorShade.color =
                        getOriginThemeData(ThemeProvider.themeOf(context).id)
                            .primaryColor;
                  }
                  return _colorShade.color;
                }(),
                elevation: 3.0,
                label: Container(
                  width: _chipWidth,
                  child: Text(''),
                ),
              ),
            )
          ],
        ),
      ),
      children: <Widget>[
        /// ActionChips: Color options
        Container(
          height: 70.0,
          child: FadingEdgeScrollView.fromScrollView(
            gradientFractionOnStart: 0.05,
            gradientFractionOnEnd: 0.05,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: controller,
              itemCount: myAppThemes.length * _shades,
              itemBuilder: (BuildContext context, int index) {
                return Visibility(
                  child: Padding(
                    padding: EdgeInsets.all(_chipPadding + _chipPaddingExtra),
                    child: ActionChip(
                      backgroundColor: () {
                        int themeIndex = index ~/ _shades;
                        Shade shade = Shade.values[index % _shades];
                        ThemeData theme = myAppThemes[themeIndex].data;

                        switch (shade) {
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
                          default:
                            return defaultColor;
                            break;
                        }
                      }(),
                      elevation: 3.0,
                      labelPadding: EdgeInsets.symmetric(
                        horizontal: _chipLabelHoriPadding,
                        vertical: _chipLabelVertPadding,
                      ),
                      label: Container(
                        width: _chipWidth,
                        child: Text(''),
                      ),
                      onPressed: () {
                        setState(() {
                          int themeIndex = index ~/ _shades;
                          Shade shade = Shade.values[index % _shades];
                          ThemeData theme = myAppThemes[themeIndex].data;

                          switch (shade) {
                            case Shade.primaryColorDark:
                              _colorShade.color = theme.primaryColorDark;
                              break;
                            case Shade.primaryColor:
                              _colorShade.color = theme.primaryColor;
                              break;
                            case Shade.accentColor:
                              _colorShade.color = theme.accentColor;
                              break;
                            case Shade.primaryColorLight:
                              _colorShade.color = theme.primaryColorLight;
                              break;
                            default:
                              break;
                          }

                          widget.valueSetterColorShade(_colorShade);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
