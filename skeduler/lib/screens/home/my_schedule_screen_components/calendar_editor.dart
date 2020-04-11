import 'package:flutter/material.dart';

class CalendarEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ListView(
          controller: ScrollController(),
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            /// Month Editor
          ],
        );
      },
    );
  }
}
