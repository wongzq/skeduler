import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:skeduler/models/my_app_themes.dart';
import 'package:skeduler/shared/functions.dart';

class ChangeColour extends StatefulWidget {
  @override
  _ChangeColourState createState() => _ChangeColourState();
}

class _ChangeColourState extends State<ChangeColour> {
  List<bool> _colourPressed = List.generate(myAppThemes.length * 4, (i) => false);
  double _bodyPadding = 20.0;
  double _chipPadding = 5;
  double _chipPaddingExtra = 2;
  double _chipLabelHoriPadding = 5;
  double _chipLabelVertPadding = 5;
  double _chipWidth;

  String _colourId;
  int _colourType = 0;

  @override
  Widget build(BuildContext context) {
    final _controller = ScrollController();

    _chipWidth = (MediaQuery.of(context).size.width - 2 * _bodyPadding) / 5 -
        (2 * _chipLabelHoriPadding) -
        (2 * _chipPadding) -
        8;

    return Container(
      padding: EdgeInsets.all(_bodyPadding),
      height: 600,
      child: Column(
        children: <Widget>[
          // Chip: Selected colour
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Group colour'),
              Padding(
                padding: EdgeInsets.all(_chipPadding + _chipPaddingExtra),
                child: Chip(
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: _chipLabelHoriPadding,
                    vertical: _chipLabelVertPadding,
                  ),
                  backgroundColor: () {
                    if (_colourType != null) {
                      if (_colourType == 0) {
                        return getNativeThemeData(
                          _colourId,
                          defaultThemeOfContext: context,
                        ).primaryColorDark;
                      } else if (_colourType == 1) {
                        return getNativeThemeData(
                          _colourId,
                          defaultThemeOfContext: context,
                        ).primaryColor;
                      } else if (_colourType == 2) {
                        return getNativeThemeData(
                          _colourId,
                          defaultThemeOfContext: context,
                        ).accentColor;
                      } else {
                        return getNativeThemeData(
                          _colourId,
                          defaultThemeOfContext: context,
                        ).primaryColorLight;
                      }
                    } else {
                      return getNativeThemeData(
                        _colourId,
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

          // ActionChips: Colour options
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
                            _colourType = index % 4;

                            _colourId = myAppThemes[newIndex].id;

                            _colourPressed =
                                List.generate(myAppThemes.length, (i) => false);
                            _colourPressed[newIndex] = true;
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
