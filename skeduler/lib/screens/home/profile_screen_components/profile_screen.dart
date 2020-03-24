import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/screens/home/profile_screen_components/editors_status.dart';
import 'package:skeduler/screens/home/profile_screen_components/day_editor.dart';
import 'package:skeduler/screens/home/profile_screen_components/month_editor.dart';
import 'package:skeduler/screens/home/profile_screen_components/time_editor.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // properties
  EditorsStatus _editorsStatus =
      EditorsStatus(currentEditor: CurrentEditor.month);
  MonthEditor _monthEditor;
  DayEditor _dayEditor;
  TimeEditor _timeEditor;

  final Duration _duration = Duration(milliseconds: 500);
  final Curve _curve = Curves.easeOutCubic;

  // methods
  void switchToMonthEditor({bool selected = false}) {
    setState(() {
      _editorsStatus.currentEditor =
          selected ? CurrentEditor.month : CurrentEditor.monthSelected;
    });
  }

  void switchToDayEditor() {
    setState(() {
      _editorsStatus.currentEditor = CurrentEditor.day;
    });
  }

  void switchToTimeEditor() {
    setState(() {
      _editorsStatus.currentEditor = CurrentEditor.time;
    });
  }

  @override
  void initState() {
    _monthEditor = MonthEditor(switchEditor: switchToMonthEditor);
    _dayEditor = DayEditor();
    _timeEditor = TimeEditor();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _editorsStatus.totalHeight = constraints.maxHeight;
        _editorsStatus.totalWidth = constraints.maxWidth;

        _editorsStatus.dividerHeight = 16.0;
        _editorsStatus.defaultSecondaryHeight = 60.0;
        _editorsStatus.defaultPrimaryHeight = _editorsStatus.totalHeight -
            2 * _editorsStatus.defaultSecondaryHeight -
            2 * _editorsStatus.dividerHeight;

        return ChangeNotifierProvider(
          create: (context) => _editorsStatus,
          child: Column(
            children: <Widget>[
              // Month Editor
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => switchToMonthEditor(),
                child: AnimatedContainer(
                  duration: _duration,
                  height: _editorsStatus.monthEditorHeight ??
                      _editorsStatus.defaultPrimaryHeight,
                  width: _editorsStatus.totalWidth,
                  curve: _curve,
                  child: _monthEditor,
                ),
              ),

              Divider(thickness: 1.0, height: _editorsStatus.dividerHeight),

              // Day Editor
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => switchToDayEditor(),
                child: AnimatedContainer(
                  duration: _duration,
                  height: _editorsStatus.dayEditorHeight ??
                      _editorsStatus.defaultSecondaryHeight,
                  width: _editorsStatus.totalWidth,
                  curve: _curve,
                  child: _dayEditor,
                ),
              ),

              Divider(thickness: 1.0, height: _editorsStatus.dividerHeight),

              // Time Editor
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => switchToTimeEditor(),
                child: AnimatedContainer(
                  duration: _duration,
                  height: _editorsStatus.timeEditorHeight ??
                      _editorsStatus.defaultSecondaryHeight,
                  width: _editorsStatus.totalWidth,
                  curve: _curve,
                  child: _timeEditor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
