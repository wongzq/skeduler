import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/screens/home/profile_screen_components/editors_status.dart';
import 'package:skeduler/shared/ui_settings.dart';

class MonthEditor extends StatefulWidget {
  // properties
  final Function switchEditor;

  // constructor
  const MonthEditor({this.switchEditor});

  // methods
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

  List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  Set<int> _monthsSelected = Set<int>();

  static const double _bodyPadding = 10.0;
  static const double _chipPadding = 5.0;
  static const double _chipLabelHoriPadding = 10.0;
  static const double _chipLabelVertPadding = 5.0;
  double _chipWidth;

  // methods
  // set the collapsed height of month editor
  setMonthEditorCollapsedHeight() {
    RenderBox text = _textKey.currentContext.findRenderObject();
    RenderBox sizedBox = _sizedBoxKey.currentContext.findRenderObject();
    RenderBox wrapSelected = _wrapSelectedKey.currentContext.findRenderObject();

    _editorsStatus.monthEditorCollapsedHeight = text.size.height +
        sizedBox.size.height +
        wrapSelected.size.height +
        2 * _bodyPadding;
  }

  // generate List<Widget> for months
  List<Widget> _generateMonths(GlobalKey _key) {
    return _months.asMap().entries.map((MapEntry item) {
      return Visibility(
        visible: () {
          if (_key == _wrapKey) {
            return _editorsStatus.currentEditor != CurrentEditor.month &&
                    _editorsStatus.currentEditor !=
                        CurrentEditor.monthSelected &&
                    !_monthsSelected.contains(item.key)
                ? false
                : true;
          } else if (_key == _wrapSelectedKey) {
            return _editorsStatus.currentEditor != CurrentEditor.month &&
                    !_monthsSelected.contains(item.key)
                ? false
                : true;
          } else {
            return null;
          }
        }(),
        child: Padding(
          padding: const EdgeInsets.all(_chipPadding),
          child: ActionChip(
            backgroundColor: _monthsSelected.contains(item.key)
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
                style: _monthsSelected.contains(item.key)
                    ? textStyleBody
                    : textStyleBodyLight,
              ),
            ),
            onPressed: () {
              setState(() {
                _editorsStatus.currentEditor = CurrentEditor.monthSelected;
                _monthsSelected.contains(item.key)
                    ? _monthsSelected.remove(item.key)
                    : _monthsSelected.add(item.key);
              });
              SchedulerBinding.instance.addPostFrameCallback((_) {
                setMonthEditorCollapsedHeight();
                setState(() {
                  _editorsStatus.currentEditor = CurrentEditor.month;
                });
              });
              widget.switchEditor(selected: false);
            },
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // note: 4 px on each side is the default Action chip padding
    _chipWidth = (MediaQuery.of(context).size.width - 2 * _bodyPadding) / 4 -
        (2 * _chipPadding) -
        (2 * _chipLabelHoriPadding) -
        8;
    print(MediaQuery.of(context).size.width);
    print(_bodyPadding);
    print(_chipPadding);
    print(_chipLabelHoriPadding);
    print(_chipWidth);
    _editorsStatus = Provider.of<EditorsStatus>(context);

    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(_bodyPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Text('Month', key: _textKey, style: textStyleHeader),
              ),
              SizedBox(key: _sizedBoxKey, height: 20.0),
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
    );
  }
}
