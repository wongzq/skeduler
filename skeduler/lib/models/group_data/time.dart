import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:quiver/core.dart';
import 'package:quiver/time.dart';

class Time {
  // properties
  DateTime startTime;
  DateTime endTime;

  Time(this.startTime, this.endTime);

  @override
  bool operator ==(o) =>
      o is Time && this.startTime == o.startTime && this.endTime == o.endTime;

  @override
  get hashCode => hash2(startTime.hashCode, endTime.hashCode);
}

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
  @required List<Weekday> weekDays,
  @required Time time,
  @required DateTime startDate,
  @required DateTime endDate,
}) {
  List<Time> times = [];

  // iterate through each month
  for (int month = 0; month < months.length; month++) {
    // iterate through each day
    for (int day = 0;
        day < daysInMonth(DateTime.now().year, month + 1);
        day++) {
      DateTime newTime =
          DateTime(DateTime.now().year, months[month].index + 1, day);

      // iterate through each weekday
      for (int weekDay = 0; weekDay < weekDays.length; weekDay++) {
        // check if weekday matches
        if (newTime.weekday == weekDays[weekDay].index + 1) {
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
            times.add(Time(newStartDateTime, newEndDateTime));
          }
        }
      }
    }
  }

  return times;
}

List<Time> generateTimesRemoveSameDay(
    List<Time> prevTimes, List<Time> newTimes) {
  prevTimes = prevTimes ?? [];
  newTimes = newTimes ?? [];
  List<Time> timesRemoveSameDay = [];

  for (int n = 0; n < newTimes.length; n++) {
    timesRemoveSameDay.add(newTimes[n]);
  }

  for (int p = 0; p < prevTimes.length; p++) {
    for (int n = 0; n < newTimes.length; n++) {
      if (!((prevTimes[p].startTime.year == newTimes[n].startTime.year &&
              prevTimes[p].startTime.month == newTimes[n].startTime.month &&
              prevTimes[p].startTime.day == newTimes[n].startTime.day) ||
          (prevTimes[p].endTime.year == newTimes[n].endTime.year &&
              prevTimes[p].endTime.month == newTimes[n].endTime.month &&
              prevTimes[p].endTime.day == newTimes[n].endTime.day))) {
        timesRemoveSameDay.add(prevTimes[p]);
      }
    }
  }

  timesRemoveSameDay.sort((a, b) {
    return a.startTime.microsecondsSinceEpoch
        .compareTo(b.startTime.microsecondsSinceEpoch);
  });

  return timesRemoveSameDay;
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
