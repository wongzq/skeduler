import 'package:flutter/material.dart';

class ScheduleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ListView(
          controller: ScrollController(),
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            // Month Editor
          ],
        );
      },
    );
  }
}
