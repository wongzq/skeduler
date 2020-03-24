import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/screens/home/profile_screen_components/editors_status.dart';
import 'package:skeduler/shared/ui_settings.dart';

class DayEditor extends StatefulWidget {
  @override
  _DayEditorState createState() => _DayEditorState();
}

class _DayEditorState extends State<DayEditor> {
  // properties
  EditorsStatus _currentEditor;

  // methods
  @override
  Widget build(BuildContext context) {
    _currentEditor = Provider.of<EditorsStatus>(context);

    return Container(
      child: Align(
        alignment: Alignment.topCenter,
        child: Text('Day', style: textStyleHeader),
      ),
    );
  }
}
