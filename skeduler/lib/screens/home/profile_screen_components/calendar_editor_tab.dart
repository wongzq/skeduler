import 'package:flutter/material.dart';

class CalendarEditorTab extends StatelessWidget {
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