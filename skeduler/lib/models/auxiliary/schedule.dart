import 'package:intl/intl.dart';
import 'package:skeduler/models/firestore/time.dart';

class Schedule {
  bool _available;

  Weekday _day;
  DateTime _startTime;
  DateTime _endTime;
  String _custom;

  String _member;
  String _subject;

  Schedule({
    bool available,
    Weekday day,
    DateTime startTime,
    DateTime endTime,
    String custom,
    String member,
    String subject,
  })  : this._available = available,
        this._day = day,
        this._startTime = startTime,
        this._endTime = endTime,
        this._custom = custom,
        this._member = member,
        this._subject = subject;

  bool get available => this._available;
  DateTime get date => this._startTime;
  String get dayStr => this._day == null ? '' : getWeekdayStr(this._day);
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
