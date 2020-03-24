import 'package:flutter/material.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimeEditor extends StatefulWidget {
  @override
  _TimeEditorState createState() => _TimeEditorState();
}

class _TimeEditorState extends State<TimeEditor> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Align(
        alignment: Alignment.topCenter,
        child: Text('Time', style: textStyleHeader),
      ),
    );
  }
}
