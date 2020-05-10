import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/group_data/time.dart';
import 'package:skeduler/screens/home/my_schedule_screen_components/availability_editor_components/editors_status.dart';
import 'package:skeduler/shared/ui_settings.dart';

class MonthEditor extends StatefulWidget {
  final ValueSetter<List<Month>> valSetMonths;

  const MonthEditor({
    Key key,
    @required this.valSetMonths,
  }) : super(key: key);

  @override
  _MonthEditorState createState() => _MonthEditorState();
}

class _MonthEditorState extends State<MonthEditor> {
  // properties
  GlobalKey _textKey = GlobalKey();
  GlobalKey _sizedBoxKey = GlobalKey();
  GlobalKey _wrapKey = GlobalKey();
  GlobalKey _wrapSelectedKey = GlobalKey();

  EditorsStatus _editorsStatus;

  List<Month> _monthsSelected = [];
  List<String> _months = List.generate(Month.values.length, (index) {
    return getMonthShortStr(Month.values[index]);
  });

  double _bodyPadding = 10.0;
  double _sizedBoxPadding = 8.0;
  double _chipPadding = 5.0;
  double _chipLabelHoriPadding = 10.0;
  double _chipLabelVertPadding = 5.0;
  double _chipWidth;

  // methods
  // set the selected height of month editor
  setMonthEditorSelectedHeight() {
    RenderBox text = _textKey.currentContext.findRenderObject();
    RenderBox sizedBox = _sizedBoxKey.currentContext.findRenderObject();
    RenderBox wrapSelected = _wrapSelectedKey.currentContext.findRenderObject();

    _editorsStatus.monthEditorSelectedHeight = text.size.height +
        sizedBox.size.height +
        wrapSelected.size.height +
        2 * _bodyPadding +
        _sizedBoxPadding;
  }

  // generate List<Widget> for months
  List<Widget> _generateMonths(GlobalKey _key) {
    OriginTheme originTheme = Provider.of<OriginTheme>(context);

    return _months.asMap().entries.map((MapEntry item) {
      return Visibility(
        visible: () {
          if (_key == _wrapKey) {
            // Chips are visible when:
            // CurrentEditor is month (visible when in MonthEditor) OR
            // CurrentEditor is monthSelected (visible when in MonthEditor) OR
            // Chip is selected (visible when not in MonthEditor)
            return _editorsStatus.currentEditor == CurrentEditor.month ||
                    _editorsStatus.currentEditor ==
                        CurrentEditor.monthSelected ||
                    _monthsSelected.contains(Month.values[item.key])
                ? true
                : false;
          } else if (_key == _wrapSelectedKey) {
            // Chips are visible when:
            // CurrentEditor is monthSelected AND Chip is selected
            return _editorsStatus.currentEditor ==
                        CurrentEditor.monthSelected &&
                    _monthsSelected.contains(Month.values[item.key])
                ? true
                : false;
          } else {
            return false;
          }
        }(),
        child: Padding(
          padding: EdgeInsets.all(_chipPadding),
          child: ActionChip(
            backgroundColor: _monthsSelected.contains(Month.values[item.key])
                ? originTheme.primaryColorLight
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
                style: _monthsSelected.contains(Month.values[item.key])
                    ? textStyleBody.copyWith(color: Colors.black)
                    : textStyleBodyLight,
              ),
            ),
            onPressed: () {
              // modify Wrap Selected
              setState(() {
                _editorsStatus.currentEditor = CurrentEditor.monthSelected;

                if (_monthsSelected.contains(Month.values[item.key])) {
                  _monthsSelected.remove(Month.values[item.key]);
                } else {
                  _monthsSelected.add(Month.values[item.key]);
                }
              });

              if (widget.valSetMonths != null) {
                widget.valSetMonths(_monthsSelected);
              }

              // get Size of Wrap Selected
              SchedulerBinding.instance.addPostFrameCallback((_) {
                setMonthEditorSelectedHeight();
                setState(() {
                  _editorsStatus.currentEditor = CurrentEditor.month;
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
        .addPostFrameCallback((_) => setMonthEditorSelectedHeight());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _editorsStatus = Provider.of<EditorsStatus>(context);

    // note: 4 px on each side is the default ActionChip padding
    _chipWidth = (MediaQuery.of(context).size.width - 2 * _bodyPadding) / 4 -
        (2 * _chipLabelHoriPadding) -
        (2 * _chipPadding) -
        8;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          setState(() => _editorsStatus.currentEditor = CurrentEditor.month),
      child: AnimatedContainer(
        duration: _editorsStatus.duration,
        curve: _editorsStatus.curve,
        height: _editorsStatus.monthEditorHeight ??
            _editorsStatus.defaultPrimaryHeight,
        width: _editorsStatus.totalWidth,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(_bodyPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Title
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: _sizedBoxPadding),
                      child: Text('Month',
                          key: _textKey, style: textStyleHeader),
                    ),
                  ),

                  SizedBox(key: _sizedBoxKey, height: _sizedBoxPadding),

                  // Body: month ActionChips
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        Wrap(
                          key: _wrapKey,
                          children: _generateMonths(_wrapKey),
                        ),
                        Visibility(
                          visible: false,
                          maintainSize: true,
                          maintainState: true,
                          maintainAnimation: true,
                          child: Wrap(
                            key: _wrapSelectedKey,
                            children: _generateMonths(_wrapSelectedKey),
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
