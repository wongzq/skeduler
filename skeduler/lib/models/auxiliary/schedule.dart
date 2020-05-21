import 'package:intl/intl.dart';
import 'package:skeduler/models/group_data/time.dart';

class Schedule {
  Weekday _day;
  DateTime _startTime;
  DateTime _endTime;
  String _custom;

  String _member;
  String _subject;

  Schedule({
    Weekday day,
    DateTime startTime,
    DateTime endTime,
    String custom,
    String member,
    String subject,
  })  : this._day = day,
        this._startTime = startTime,
        this._endTime = endTime,
        this._custom = custom,
        this._member = member,
        this._subject = subject;

  DateTime get date => DateTime(
      this._startTime.year, this._startTime.month, this._startTime.day);
  String get dayStr => this._day == null ? '' : getWeekdayShortStr(this._day);
  String get monthStr =>
      this._startTime == null ? '' : DateFormat('MMMM').format(this._startTime);
  String get dateStr => this._startTime == null
      ? ''
      : DateFormat('dd MMM').format(this._startTime);
  String get startTimeStr => this._startTime == null
      ? ''
      : DateFormat('hh:mm aa').format(this._startTime) ?? '';
  String get endTimeStr => this._endTime == null
      ? ''
      : DateFormat('hh:mm aa').format(this._endTime) ?? '';
  String get custom => this._custom ?? '';
  String get member => this._member ?? '';
  String get subject => this._subject ?? '';
}
