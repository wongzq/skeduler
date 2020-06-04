import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:quiver/core.dart';
import 'package:quiver/time.dart';

// --------------------------------------------------------------------------------
// Time class
// --------------------------------------------------------------------------------

class Time {
  // properties
  DateTime startTime;
  DateTime endTime;

  // constructors
  Time({this.startTime, this.endTime});

  Time.from(Time time)
      : this.startTime = time.startTime,
        this.endTime = time.endTime;

  // getter methods
  DateTime get startDate => DateTime(
        startTime.year,
        startTime.month,
        startTime.day,
      );
  DateTime get endDate => DateTime(
        endTime.year,
        endTime.month,
        endTime.day,
      );

  // getter methods
  int get startTimeInt => startTime.millisecondsSinceEpoch;
  int get endTimeInt => endTime.millisecondsSinceEpoch;
  String get startTimeStr => DateFormat('hh:mm aa').format(startTime);
  String get endTimeStr => DateFormat('hh:mm aa').format(endTime);

  // auxiliary methods
  bool sameDateAs(Time time) {
    return this.startDate == time.startDate && this.endDate == time.endDate;
  }

  bool withinDateTimeOf(Time time) {
    return this.startTime.millisecondsSinceEpoch >=
            time.startTime.millisecondsSinceEpoch &&
        this.endTime.millisecondsSinceEpoch <=
            time.endTime.millisecondsSinceEpoch;
  }

  bool notWithinDateTimeOf(Time time) {
    return this.endTime.millisecondsSinceEpoch <=
            time.startTime.millisecondsSinceEpoch ||
        this.startTime.millisecondsSinceEpoch >=
            time.endTime.millisecondsSinceEpoch;
  }

  bool withinTimeOf(Time time) {
    // only checks time, so changes the date to be the same
    Time tmpTime = Time(
      startTime: DateTime(
        this.startTime.year,
        this.startTime.month,
        this.startTime.day,
        time.startTime.hour,
        time.startTime.minute,
      ),
      endTime: DateTime(
        this.endTime.year,
        this.endTime.month,
        this.endTime.day,
        time.endTime.hour,
        time.endTime.minute,
      ),
    );

    return this.startTime.millisecondsSinceEpoch >=
            tmpTime.startTime.millisecondsSinceEpoch &&
        this.endTime.millisecondsSinceEpoch <=
            tmpTime.endTime.millisecondsSinceEpoch;
  }

  bool notWithinTimeOf(Time time) {
    // only checks time, so changes the date to be the same
    Time tmpTime = Time(
      startTime: DateTime(
        this.startTime.year,
        this.startTime.month,
        this.startTime.day,
        time.startTime.hour,
        time.startTime.minute,
      ),
      endTime: DateTime(
        this.endTime.year,
        this.endTime.month,
        this.endTime.day,
        time.endTime.hour,
        time.endTime.minute,
      ),
    );

    if (this.endTime.isBefore(tmpTime.startTime) ||
        this.endTime.isAtSameMomentAs(tmpTime.startTime) ||
        this.startTime.isAfter(tmpTime.endTime) ||
        this.startTime.isAtSameMomentAs(tmpTime.endTime)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  bool operator ==(o) =>
      o is Time && this.startTime == o.startTime && this.endTime == o.endTime;

  @override
  int get hashCode => hash2(this.startTime, this.endTime);

  @override
  String toString() {
    return startTime.toString() + ' ' + endTime.toString() + '\n';
  }
}

// --------------------------------------------------------------------------------
// Auxiliary functions
// --------------------------------------------------------------------------------

String getTimeStr(Time time) {
  return DateFormat('HHmm').format(time.startTime) +
      ' ' +
      DateFormat('HHmm').format(time.endTime);
}

enum Month { jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec }

enum Weekday { mon, tue, wed, thu, fri, sat, sun }

String getMonthShortStr(Month month) {
  switch (month) {
    case Month.jan:
      return 'Jan';
      break;
    case Month.feb:
      return 'Feb';
      break;
    case Month.mar:
      return 'Mar';
      break;
    case Month.apr:
      return 'Apr';
      break;
    case Month.may:
      return 'May';
      break;
    case Month.jun:
      return 'Jun';
      break;
    case Month.jul:
      return 'Jul';
      break;
    case Month.aug:
      return 'Aug';
      break;
    case Month.sep:
      return 'Sep';
      break;
    case Month.oct:
      return 'Oct';
      break;
    case Month.nov:
      return 'Nov';
      break;
    case Month.dec:
      return 'Dec';
      break;
    default:
      return '';
  }
}

String getMonthStr(Month month) {
  switch (month) {
    case Month.jan:
      return 'January';
      break;
    case Month.feb:
      return 'February';
      break;
    case Month.mar:
      return 'March';
      break;
    case Month.apr:
      return 'April';
      break;
    case Month.may:
      return 'May';
      break;
    case Month.jun:
      return 'June';
      break;
    case Month.jul:
      return 'July';
      break;
    case Month.aug:
      return 'August';
      break;
    case Month.sep:
      return 'September';
      break;
    case Month.oct:
      return 'October';
      break;
    case Month.nov:
      return 'November';
      break;
    case Month.dec:
      return 'December';
      break;
    default:
      return '';
  }
}

String getWeekdayShortStr(Weekday weekday) {
  switch (weekday) {
    case Weekday.mon:
      return 'Mon';
      break;
    case Weekday.tue:
      return 'Tue';
      break;
    case Weekday.wed:
      return 'Wed';
      break;
    case Weekday.thu:
      return 'Thu';
      break;
    case Weekday.fri:
      return 'Fri';
      break;
    case Weekday.sat:
      return 'Sat';
      break;
    case Weekday.sun:
      return 'Sun';
      break;
    default:
      return '';
  }
}

String getWeekdayStr(Weekday weekday) {
  switch (weekday) {
    case Weekday.mon:
      return 'Monday';
      break;
    case Weekday.tue:
      return 'Tuesday';
      break;
    case Weekday.wed:
      return 'Wednesday';
      break;
    case Weekday.thu:
      return 'Thursday';
      break;
    case Weekday.fri:
      return 'Friday';
      break;
    case Weekday.sat:
      return 'Saturday';
      break;
    case Weekday.sun:
      return 'Sunday';
      break;
    default:
      return '';
  }
}

List<Time> generateTimes({
  @required List<Month> months,
  @required List<Weekday> weekdays,
  @required Time time,
  @required DateTime startDate,
  @required DateTime endDate,
}) {
  List<Time> times = [];

  // iterate through each month
  for (int month = 0; month < months.length; month++) {
    // iterate through each day
    for (int day = 0;
        day < daysInMonth(DateTime.now().year, months[month].index + 1);
        day++) {
      DateTime newTime =
          DateTime(DateTime.now().year, months[month].index + 1, day + 1);

      // iterate through each weekday
      for (int weekDay = 0; weekDay < weekdays.length; weekDay++) {
        // check if weekday matches
        if (newTime.weekday == weekdays[weekDay].index + 1) {
          // create startDateTime
          DateTime newStartDateTime = DateTime(
            newTime.year,
            newTime.month,
            newTime.day,
            time.startTime.hour,
            time.startTime.minute,
          );

          // create endDateTime
          DateTime newEndDateTime = DateTime(
            newTime.year,
            newTime.month,
            newTime.day,
            time.endTime.hour,
            time.endTime.minute,
          );

          if ((newStartDateTime.isAtSameMomentAs(startDate) ||
                  newStartDateTime.isAfter(startDate)) &&
              (newEndDateTime
                      .isAtSameMomentAs(endDate.add(Duration(days: 1))) ||
                  newEndDateTime.isBefore(endDate.add(Duration(days: 1))))) {
            times.add(Time(
              startTime: newStartDateTime,
              endTime: newEndDateTime,
            ));
          }
        }
      }
    }
  }

  return times;
}

// auxiliary function to check if all [Time] in [List<Time>] is consecutive with no conflicts of time
bool isConsecutiveTimes(List<Time> times) {
  bool isConsecutive = true;

  // sort the area in terms of startTime
  times.sort((a, b) {
    return a.startTime.millisecondsSinceEpoch
        .compareTo(b.startTime.millisecondsSinceEpoch);
  });

  // loop through the array to find any conflict
  for (int i = 0; i < times.length; i++) {
    if (i != 0) {
      // if conflict is found, returns [hasNoConflict] as [false]
      if (!(times[i - 1].startTime.isBefore(times[i].startTime) &&
          times[i - 1].endTime.isBefore(times[i].endTime) &&
          (times[i - 1].endTime.isBefore(times[i].startTime) ||
              times[i - 1].endTime.isAtSameMomentAs(times[i].startTime)))) {
        isConsecutive = false;
        break;
      }
    }
  }

  return isConsecutive;
}
