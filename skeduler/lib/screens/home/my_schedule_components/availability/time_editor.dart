import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/time.dart';
import 'package:skeduler/screens/home/my_schedule_components/availability/date_selector.dart';
import 'package:skeduler/screens/home/my_schedule_components/availability/time_selector.dart';
import 'package:skeduler/screens/home/my_schedule_components/availability/editors_status.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class TimeEditor extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final ValueGetter<List<Month>> valGetMonths;
  final ValueGetter<List<Weekday>> valGetWeekdays;

  const TimeEditor({
    Key key,
    @required this.scaffoldKey,
    @required this.valGetMonths,
    @required this.valGetWeekdays,
  }) : super(key: key);

  @override
  _TimeEditorState createState() => _TimeEditorState();
}

class _TimeEditorState extends State<TimeEditor> {
  // properties
  OriginTheme _originTheme;
  DatabaseService _dbService;
  GroupStatus _groupStatus;

  GlobalKey _textKey = GlobalKey();
  GlobalKey _sizedBoxKey = GlobalKey();
  GlobalKey _buttonsKey = GlobalKey();

  EditorsStatus _editorsStatus;

  DateTime _defaultStartDate;
  DateTime _defaultEndDate;
  DateTime _startDate;
  DateTime _endDate;

  DateTime _defaultStartTime;
  DateTime _defaultEndTime;
  DateTime _startTime;
  DateTime _endTime;

  bool _validTime = false;
  bool _validDate = false;

  bool _dateRangeExpanded;
  bool _timeRangeExpanded;
  bool _savePressed = false;
  bool _removeDaysPressed = false;
  bool _resetPressed = false;

  double _spacing = 5.0;
  double _bodyPadding = 10.0;
  double _centerWidth = 20.0;
  double _buttonHeight = 45.0;

  // methods
  // set the selected height of time editor
  void setTimeEditorSelectedHeight() {
    RenderBox text = _textKey.currentContext.findRenderObject();
    RenderBox sizedBox = _sizedBoxKey.currentContext.findRenderObject();
    RenderBox buttons = _buttonsKey.currentContext.findRenderObject();

    _editorsStatus.timeEditorSelectedHeight = text.size.height +
        sizedBox.size.height +
        buttons.size.height +
        2 * _bodyPadding;
  }

  Widget _generateSaveButton() {
    bool saveEnabled = _validDate && _validTime
        ? true
        // if date is set, and both times not set
        : _validDate && _startTime == null && _endTime == null
            ? true
            // if time is set, and both dates not set
            : _validTime && _startDate == null && _endDate == null
                ? true
                // if all not set
                : _startDate == null &&
                        _endDate == null &&
                        _startTime == null &&
                        _endTime == null
                    ? true
                    : false;

    return Padding(
      padding: EdgeInsets.all(_spacing),
      child: Container(
        height: _buttonHeight,
        width: MediaQuery.of(context).size.width - 2,
        child: RaisedButton(
          onHighlightChanged: (value) => setState(() => _savePressed = value),
          color: _originTheme.primaryColorLight,
          disabledColor: Colors.grey.shade200,
          disabledTextColor: Color(0xFFBBBBBB),
          highlightColor: _originTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 3.0,
          onPressed: saveEnabled
              ? () async {
                  List<Time> newTimes = [];

                  newTimes = generateTimes(
                    months: widget.valGetMonths(),
                    weekdays: widget.valGetWeekdays(),
                    time: Time(
                      startTime: _startTime ??
                          DateTime(DateTime.now().year, 1, 1, 0, 0),
                      endTime: _endTime ??
                          DateTime(DateTime.now().year, 1, 1, 23, 59),
                    ),
                    startDate: _startDate ?? _defaultStartDate,
                    endDate: _endDate ?? _defaultEndDate,
                  );

                  widget.scaffoldKey.currentState.showSnackBar(LoadingSnackBar(
                      context, 'Updating available times . . .'));

                  if (_groupStatus.member.alwaysAvailable) {
                    await _dbService.updateGroupMemberTimes(
                      _groupStatus.group.docId,
                      _groupStatus.member.docId,
                      newTimes,
                      true,
                    );
                  } else {
                    await _dbService.updateGroupMemberTimes(
                      _groupStatus.group.docId,
                      _groupStatus.member.docId,
                      newTimes,
                      false,
                    );
                  }

                  widget.scaffoldKey.currentState.hideCurrentSnackBar();
                }
              : null,
          child: Text(
            'SAVE',
            style: TextStyle(
              color: saveEnabled
                  ? _savePressed ? _originTheme.textColor : Colors.black
                  : Colors.grey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _generateRemoveDaysButton() {
    bool removeDaysEnabled =
        _validDate || (_startDate == null && _endDate == null);

    return Padding(
      padding: EdgeInsets.all(_spacing),
      child: Container(
        height: _buttonHeight,
        width: MediaQuery.of(context).size.width - 2,
        child: RaisedButton(
          onHighlightChanged: (value) =>
              setState(() => _removeDaysPressed = value),
          color: Colors.red.shade300,
          disabledColor: Colors.grey.shade200,
          disabledTextColor: Color(0xFFBBBBBB),
          highlightColor: Colors.red.shade500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 3.0,
          onPressed: removeDaysEnabled
              ? () async {
                  await showDialog(
                    context: context,
                    builder: (context) {
                      DateTime tmpStartDate = _startDate ?? _defaultStartDate;
                      DateTime tmpEndDate = _endDate ?? _defaultEndDate;
                      DateTime tmpStartTime = _startTime ?? _defaultStartTime;
                      DateTime tmpEndTime = _endTime ?? _defaultEndTime;

                      return SimpleAlertDialog(
                        context: context,
                        titleDisplay: _groupStatus.member.alwaysAvailable
                            ? 'Remove from your unavailable times?'
                            : 'Remove from your available times?',
                        contentDisplay:
                            DateFormat('EEEE, d MMMM').format(tmpStartDate) +
                                ' to ' +
                                DateFormat('EEEE, d MMMM').format(tmpEndDate),
                        confirmDisplay: 'REMOVE',
                        confirmFunction: () async {
                          Navigator.of(context).maybePop();

                          widget.scaffoldKey.currentState.showSnackBar(
                              LoadingSnackBar(
                                  context, 'Updating available times . . .'));

                          List<Time> removeTimes = generateTimes(
                            months: widget.valGetMonths(),
                            weekdays: widget.valGetWeekdays(),
                            time: Time(
                              startTime: tmpStartTime,
                              endTime: tmpEndTime,
                            ),
                            startDate: tmpStartDate,
                            endDate: tmpEndDate,
                          );

                          await _dbService
                              .removeGroupMemberTimes(
                            _groupStatus.group.docId,
                            _groupStatus.member.docId,
                            removeTimes,
                            _groupStatus.member.alwaysAvailable,
                          )
                              .then(
                            (_) {
                              widget.scaffoldKey.currentState
                                  .hideCurrentSnackBar();
                            },
                          );
                        },
                      );
                    },
                  );
                }
              : null,
          child: Text(
            'REMOVE DAYS',
            style: TextStyle(
              color: removeDaysEnabled
                  ? _removeDaysPressed ? Colors.white : Colors.black
                  : Colors.grey,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _generateResetButton() {
    return Padding(
      padding: EdgeInsets.all(_spacing),
      child: Container(
        height: _buttonHeight,
        width: MediaQuery.of(context).size.width - 2,
        child: RaisedButton(
          onHighlightChanged: (value) => setState(() => _resetPressed = value),
          color: _originTheme.primaryColorLight,
          highlightColor: _originTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          elevation: 3.0,
          onPressed: () {
            setState(() {
              _startTime = null;
              _endTime = null;

              _startDate = null;
              _endDate = null;
            });
          },
          child: Text(
            'RESET',
            style: TextStyle(
              color: _resetPressed ? _originTheme.textColor : Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _defaultStartTime = DateTime(DateTime.now().year, 1, 1, 0, 0);
    _defaultEndTime = DateTime(DateTime.now().year, 1, 1, 23, 59);

    _dateRangeExpanded = true;
    _timeRangeExpanded = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setTimeEditorSelectedHeight();
      setState(() {
        _dateRangeExpanded = false;
        _timeRangeExpanded = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _originTheme = Provider.of<OriginTheme>(context);
    _dbService = Provider.of<DatabaseService>(context);
    _groupStatus = Provider.of<GroupStatus>(context);
    _editorsStatus = Provider.of<EditorsStatus>(context);

    _defaultStartDate = getFirstDayOfStartMonth(widget.valGetMonths()) ??
        _defaultStartDate ??
        DateTime.now();
    _defaultEndDate = getLastDayOfLastMonth(widget.valGetMonths()) ??
        _defaultEndDate ??
        DateTime.now();

    return AbsorbPointer(
      absorbing:
          widget.valGetMonths().isEmpty || widget.valGetWeekdays().isEmpty,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            setState(() => _editorsStatus.currentEditor = CurrentEditor.time),
        child: AnimatedContainer(
          duration: _editorsStatus.duration,
          curve: _editorsStatus.curve,
          height: _editorsStatus.timeEditorHeight ??
              _editorsStatus.defaultSecondaryHeight,
          width: _editorsStatus.totalWidth,
          child: Padding(
            padding: EdgeInsets.all(_bodyPadding),
            child: Column(
              children: <Widget>[
                // Title
                Align(
                  alignment: Alignment.topCenter,
                  child: Text('Time', key: _textKey, style: textStyleHeader),
                ),

                SizedBox(key: _sizedBoxKey, height: _spacing),

                // Body: Set Time Buttons
                Visibility(
                  visible: _editorsStatus.currentEditor == CurrentEditor.time,
                  maintainSize: true,
                  maintainState: true,
                  maintainAnimation: true,
                  child: Column(
                    key: _buttonsKey,
                    children: <Widget>[
                      // Date Range
                      Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          key: GlobalKey(),
                          initiallyExpanded: _dateRangeExpanded,
                          onExpansionChanged: (value) {
                            setState(() {
                              _dateRangeExpanded = value;
                            });
                          },
                          title: Text(
                            'Date range (optional)',
                            style: textStyleBodyLight.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          trailing: Icon(
                            _dateRangeExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.grey,
                          ),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                // Button: Start Date
                                DateSelector(
                                  context: context,
                                  type: DateSelectorType.start,
                                  valSetStartDate: (value) =>
                                      setState(() => _startDate = value),
                                  valSetEndDate: (value) =>
                                      setState(() => _endDate = value),
                                  valSetValidDate: (value) =>
                                      setState(() => _validDate = value),
                                  valGetStartDate: () => _startDate,
                                  valGetEndDate: () => _endDate,
                                  valGetMonths: () => widget.valGetMonths(),
                                ),

                                SizedBox(width: _spacing),
                                Container(
                                  alignment: Alignment.center,
                                  width: _centerWidth,
                                  child: Text(
                                    'to',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                SizedBox(width: _spacing),

                                // Button: End Date
                                DateSelector(
                                  context: context,
                                  type: DateSelectorType.end,
                                  valSetStartDate: (value) =>
                                      setState(() => _startDate = value),
                                  valSetEndDate: (value) =>
                                      setState(() => _endDate = value),
                                  valSetValidDate: (value) =>
                                      setState(() => _validDate = value),
                                  valGetStartDate: () => _startDate,
                                  valGetEndDate: () => _endDate,
                                  valGetMonths: () => widget.valGetMonths(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Time Range
                      Theme(
                        data: Theme.of(context)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          key: GlobalKey(),
                          initiallyExpanded: _timeRangeExpanded,
                          onExpansionChanged: (value) {
                            setState(() {
                              _timeRangeExpanded = value;
                            });
                          },
                          title: Text(
                            'Time range (optional)',
                            style: textStyleBodyLight.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          trailing: Icon(
                            _timeRangeExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.grey,
                          ),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                // Button: Start Time
                                TimeSelector(
                                  context: context,
                                  type: TimeSelectorType.start,
                                  valSetStartTime: (value) =>
                                      setState(() => _startTime = value),
                                  valSetEndTime: (value) =>
                                      setState(() => _endTime = value),
                                  valSetValidTime: (value) =>
                                      setState(() => _validTime = value),
                                  valGetStartTime: () => _startTime,
                                  valGetEndTime: () => _endTime,
                                ),

                                SizedBox(width: _spacing),
                                Container(
                                  alignment: Alignment.center,
                                  width: _centerWidth,
                                  child: Text(
                                    'to',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                SizedBox(width: _spacing),

                                // Button: End Time
                                TimeSelector(
                                  context: context,
                                  type: TimeSelectorType.end,
                                  valSetStartTime: (value) =>
                                      setState(() => _startTime = value),
                                  valSetEndTime: (value) =>
                                      setState(() => _endTime = value),
                                  valSetValidTime: (value) =>
                                      setState(() => _validTime = value),
                                  valGetStartTime: () => _startTime,
                                  valGetEndTime: () => _endTime,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: _spacing),
                      // Button: Save
                      _generateSaveButton(),
                      SizedBox(height: _spacing),
                      // Button: Remove
                      _generateRemoveDaysButton(),
                      SizedBox(height: _spacing),
                      // Button: Reset
                      _generateResetButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
