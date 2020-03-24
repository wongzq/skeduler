import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/screens/home/profile_screen_components/editors_status.dart';
import 'package:skeduler/shared/ui_settings.dart';

class TimeEditor extends StatefulWidget {
  @override
  _TimeEditorState createState() => _TimeEditorState();
}

class _TimeEditorState extends State<TimeEditor> {
  // properties
  EditorsStatus _editorsStatus;

  // methods
  void switchToTimeEditor() =>
      setState(() => _editorsStatus.currentEditor = CurrentEditor.time);

  @override
  Widget build(BuildContext context) {
    _editorsStatus = Provider.of<EditorsStatus>(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => switchToTimeEditor(),
      child: AnimatedContainer(
        duration: _editorsStatus.duration,
        curve: _editorsStatus.curve,
        height: _editorsStatus.timeEditorHeight ??
            _editorsStatus.defaultSecondaryHeight,
        width: _editorsStatus.totalWidth,
        child: Container(
          child: Align(
            alignment: Alignment.topCenter,
            child: Text('Time', style: textStyleHeader),
          ),
        ),
      ),
    );
  }
}
