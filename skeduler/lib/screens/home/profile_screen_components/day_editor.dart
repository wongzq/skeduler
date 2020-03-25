import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/screens/home/profile_screen_components/editors_status.dart';
import 'package:skeduler/shared/ui_settings.dart';

class DayEditor extends StatefulWidget {
  @override
  _DayEditorState createState() => _DayEditorState();
}

class _DayEditorState extends State<DayEditor> {
  // properties
  GlobalKey _textKey = GlobalKey();
  GlobalKey _sizedBoxKey = GlobalKey();
  GlobalKey _wrapKey = GlobalKey();
  GlobalKey _wrapSelectedKey = GlobalKey();

  EditorsStatus _editorsStatus;

  List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Set<int> _daysSelected = Set<int>();

  static const double _bodyPadding = 10.0;
  static const double _chipPadding = 5.0;
  static const double _chipLabelHoriPadding = 10.0;
  static const double _chipLabelVertPadding = 5.0;
  double _chipWidth;

  // methods
  // set the selected height of day editor
  setDayEditorSelectedHeight() {
    RenderBox text = _textKey.currentContext.findRenderObject();
    RenderBox sizedBox = _sizedBoxKey.currentContext.findRenderObject();
    RenderBox wrapSelected = _wrapSelectedKey.currentContext.findRenderObject();

    _editorsStatus.dayEditorSelectedHeight = text.size.height +
        sizedBox.size.height +
        wrapSelected.size.height +
        2 * _bodyPadding;
  }

  // generate List<Widget> for days
  List<Widget> _generateDays(GlobalKey _key) {
    return _days.asMap().entries.map((MapEntry item) {
      return Visibility(
        visible: () {
          if (_key == _wrapKey) {
            // Chips are visible when:
            // CurrentEditor is day (visible when in DayEditor) OR
            // CurrentEditor is daySelected (visible when in DayEditor) OR
            // Chip is selected (visible when not in DayEditor)
            return _editorsStatus.currentEditor == CurrentEditor.day ||
                    _editorsStatus.currentEditor == CurrentEditor.daySelected ||
                    _daysSelected.contains(item.key)
                ? true
                : false;
          } else if (_key == _wrapSelectedKey) {
            // Chips are visible when:
            // CurrentEditor is daySelected AND Chip is selected
            return _editorsStatus.currentEditor == CurrentEditor.daySelected &&
                    _daysSelected.contains(item.key)
                ? true
                : false;
          } else {
            return false;
          }
        }(),
        child: Padding(
          padding: const EdgeInsets.all(_chipPadding),
          child: ActionChip(
            backgroundColor: _daysSelected.contains(item.key)
                ? Theme.of(context).primaryColorLight
                : Colors.grey[200],
            elevation: 3.0,
            labelPadding: EdgeInsets.symmetric(
              horizontal: _chipLabelHoriPadding,
              vertical: _chipLabelVertPadding,
            ),
            label: Container(
              width: _chipWidth,
              child: Text(
                item.value,
                style: _daysSelected.contains(item.key)
                    ? textStyleBody
                    : textStyleBodyLight,
              ),
            ),
            onPressed: () {
              // modify Wrap Selected
              setState(() {
                _editorsStatus.currentEditor = CurrentEditor.daySelected;
                _daysSelected.contains(item.key)
                    ? _daysSelected.remove(item.key)
                    : _daysSelected.add(item.key);
              });

              // get Size of Wrap Selected
              SchedulerBinding.instance.addPostFrameCallback((_) {
                setDayEditorSelectedHeight();
                setState(() {
                  _editorsStatus.currentEditor = CurrentEditor.day;
                });
              });
            },
          ),
        ),
      );
    }).toList();
  }

  @override
  void initState() {
    SchedulerBinding.instance
        .addPostFrameCallback((_) => setDayEditorSelectedHeight());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _editorsStatus = Provider.of<EditorsStatus>(context);

    // note: 4px on each side is the default ActionChip padding
    _chipWidth = (MediaQuery.of(context).size.width - 2 * _bodyPadding) / 4 -
        (2 * _chipPadding) -
        (2 * _chipLabelHoriPadding) -
        8;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          setState(() => _editorsStatus.currentEditor = CurrentEditor.day),
      child: AnimatedContainer(
        duration: _editorsStatus.duration,
        curve: _editorsStatus.curve,
        height: _editorsStatus.dayEditorHeight ??
            _editorsStatus.defaultSecondaryHeight,
        width: _editorsStatus.totalWidth,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(_bodyPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Title
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text('Day', key: _textKey, style: textStyleHeader),
                  ),

                  SizedBox(key: _sizedBoxKey, height: 8.0),
                  
                  // Body: Day ActionChips
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        Wrap(
                          key: _wrapKey,
                          children: _generateDays(_wrapKey),
                        ),
                        Visibility(
                          visible: false,
                          maintainSize: true,
                          maintainState: true,
                          maintainAnimation: true,
                          child: Wrap(
                            key: _wrapSelectedKey,
                            children: _generateDays(_wrapSelectedKey),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
