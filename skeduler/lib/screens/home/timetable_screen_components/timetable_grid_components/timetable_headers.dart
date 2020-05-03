import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/screens/home/timetable_screen_components/timetable_grid_components/timetable_grid_box.dart';

// --------------------------------------------------------------------------------
// Timetable Header X
// --------------------------------------------------------------------------------

class TimetableHeaderX extends StatefulWidget {
  final List<String> axisX;

  const TimetableHeaderX({
    Key key,
    this.axisX = const [],
  }) : super(key: key);

  @override
  _TimetableHeaderXState createState() => _TimetableHeaderXState();
}

class _TimetableHeaderXState extends State<TimetableHeaderX> {
  ScrollController horiScroll;

  @override
  Widget build(BuildContext context) {
    TimetableAxes axes = Provider.of<TimetableAxes>(context);
    TimetableScroll ttbScroll = Provider.of<TimetableScroll>(context);

    horiScroll = horiScroll ?? ttbScroll.hori.addAndGet();

    return Row(
      children: () {
        List<Widget> rows = [];

        // Add Switch button
        String display = 'Axis';
        rows.add(TimetableGridBox(
          gridBoxType: GridBoxType.switchBox,
          initialDisplay: display,
          heightRatio: 1,
          widthRatio: 2,
          axes: axes,
        ));

        List<Widget> headerX = [];

        for (int i = 0; i < widget.axisX.length; i++) {
          String display = widget.axisX[i];
          headerX.add(TimetableGridBox(
            gridBoxType: GridBoxType.header,
            initialDisplay: display,
            heightRatio: 1,
            widthRatio: 1,
          ));
        }

        rows.add(
          Expanded(
            child: SingleChildScrollView(
              controller: horiScroll,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: headerX,
              ),
            ),
          ),
        );

        return rows;
      }(),
    );
  }
}

// --------------------------------------------------------------------------------
// Timetable Header Y & Z
// --------------------------------------------------------------------------------

class TimetableHeaderYZ extends StatefulWidget {
  final List<String> axisY;
  final List<String> axisZ;

  TimetableHeaderYZ({Key key, this.axisY, this.axisZ}) : super(key: key);

  @override
  _TimetableHeaderYZState createState() => _TimetableHeaderYZState();
}

class _TimetableHeaderYZState extends State<TimetableHeaderYZ> {
  ScrollController vertScroll;

  @override
  Widget build(BuildContext context) {
    TimetableScroll ttbScroll = Provider.of<TimetableScroll>(context);
    vertScroll = vertScroll ?? ttbScroll.vert.addAndGet();

    return SingleChildScrollView(
      controller: vertScroll,
      scrollDirection: Axis.vertical,
      child: Column(
        children: () {
          List<Widget> headers = [];

          widget.axisY.forEach((y) {
            headers.add(
              Row(
                children: <Widget>[
                  TimetableHeaderY(
                    axisY: widget.axisY,
                    index: widget.axisY.indexOf(y),
                    zLength: widget.axisZ.length,
                  ),
                  TimetableHeaderZ(axisZ: widget.axisZ),
                ],
              ),
            );
          });

          return headers;
        }(),
      ),
    );
  }
}

// --------------------------------------------------------------------------------
// Timetable Header Y
// --------------------------------------------------------------------------------

class TimetableHeaderY extends StatefulWidget {
  final List<String> axisY;
  final int index;
  final int zLength;

  const TimetableHeaderY({
    Key key,
    this.axisY,
    this.index = -1,
    this.zLength,
  }) : super(key: key);

  @override
  _TimetableHeaderYState createState() => _TimetableHeaderYState();
}

class _TimetableHeaderYState extends State<TimetableHeaderY> {
  @override
  Widget build(BuildContext context) {
    String display = widget.axisY[widget.index];
    return TimetableGridBox(
      gridBoxType: GridBoxType.header,
      initialDisplay: display,
      heightRatio: widget.zLength.toDouble(),
      widthRatio: 1,
      textOverFlowFade: false,
    );
  }
}

// --------------------------------------------------------------------------------
// Timetable Header Z
// --------------------------------------------------------------------------------

class TimetableHeaderZ extends StatelessWidget {
  final List<String> axisZ;

  const TimetableHeaderZ({
    Key key,
    this.axisZ,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> colContents = [];

    axisZ.forEach((z) {
      String display = z;

      colContents.add(
        TimetableGridBox(
          gridBoxType: GridBoxType.header,
          initialDisplay: display,
          textOverFlowFade: false,
          heightRatio: 1,
          widthRatio: 1,
        ),
      );
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: colContents,
    );
  }
}
