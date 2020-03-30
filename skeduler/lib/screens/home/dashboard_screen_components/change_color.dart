import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:skeduler/models/my_app_themes.dart';
import 'package:skeduler/shared/functions.dart';

class ChangeColor extends StatefulWidget {
  /// properties
  final ValueSetter<Color> valueSetter;

  /// constructor
  const ChangeColor({this.valueSetter});

  @override
  _ChangeColorState createState() => _ChangeColorState();
}

class _ChangeColorState extends State<ChangeColor> {
  List<bool> _colorPressed =
      List.generate(myAppThemes.length * 4, (i) => false);
  double _bodyHoriPadding = 20.0;
  double _bodyVertPadding = 20.0;
  double _chipPadding = 5;
  double _chipPaddingExtra = 2;
  double _chipLabelHoriPadding = 5;
  double _chipLabelVertPadding = 5;
  double _chipWidth;

  String _colorId;
  int _colorType = 0;

  @override
  Widget build(BuildContext context) {
    ScrollController _controller = ScrollController();

    _chipWidth =
        (MediaQuery.of(context).size.width - 2 * _bodyHoriPadding) / 5 -
            (2 * _chipLabelHoriPadding) -
            (2 * _chipPadding) -
            8;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _bodyHoriPadding,
        vertical: _bodyVertPadding,
      ),
      child: Column(
        children: <Widget>[
          /// Chip: Selected color
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Color',
                style: TextStyle(
                  fontSize: 15.0,
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
                    if (_colorType != null) {
                      if (_colorType == 0) {
                        return getNativeThemeData(
                          _colorId,
                          defaultThemeOfContext: context,
                        ).primaryColorDark;
                      } else if (_colorType == 1) {
                        return getNativeThemeData(
                          _colorId,
                          defaultThemeOfContext: context,
                        ).primaryColor;
                      } else if (_colorType == 2) {
                        return getNativeThemeData(
                          _colorId,
                          defaultThemeOfContext: context,
                        ).accentColor;
                      } else {
                        return getNativeThemeData(
                          _colorId,
                          defaultThemeOfContext: context,
                        ).primaryColorLight;
                      }
                    } else {
                      return getNativeThemeData(
                        _colorId,
                        defaultThemeOfContext: context,
                      ).primaryColor;
                    }
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

          /// ActionChips: Color options
          Container(
            height: 70.0,
            child: FadingEdgeScrollView.fromScrollView(
              gradientFractionOnStart: 0.05,
              gradientFractionOnEnd: 0.05,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: _controller,
                itemCount: myAppThemes.length * 4,
                itemBuilder: (BuildContext context, int index) {
                  return Visibility(
                    child: Padding(
                      padding: EdgeInsets.all(_chipPadding + _chipPaddingExtra),
                      child: ActionChip(
                        backgroundColor: () {
                          int newIndex = index ~/ 4;

                          if (index % 4 == 0) {
                            return myAppThemes[newIndex].data.primaryColorDark;
                          } else if (index % 4 == 1) {
                            return myAppThemes[newIndex].data.primaryColor;
                          } else if (index % 4 == 2) {
                            return myAppThemes[newIndex].data.accentColor;
                          } else {
                            return myAppThemes[newIndex].data.primaryColorLight;
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
                            int newIndex = index ~/ 4;
                            _colorType = index % 4;

                            _colorId = myAppThemes[newIndex].id;

                            _colorPressed =
                                List.generate(myAppThemes.length, (i) => false);
                            _colorPressed[newIndex] = true;

                            Color _selectedColor;
                            if (index % 4 == 0) {
                              _selectedColor =
                                  myAppThemes[newIndex].data.primaryColorDark;
                            } else if (index % 4 == 1) {
                              _selectedColor =
                                  myAppThemes[newIndex].data.primaryColor;
                            } else if (index % 4 == 2) {
                              _selectedColor =
                                  myAppThemes[newIndex].data.accentColor;
                            } else {
                              _selectedColor =
                                  myAppThemes[newIndex].data.primaryColorLight;
                            }

                            widget.valueSetter(_selectedColor);
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
      ),
    );
  }
}
