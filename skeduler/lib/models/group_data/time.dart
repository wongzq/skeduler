import 'package:flutter/foundation.dart';
import 'package:quiver/time.dart';

class Time {
  /// properties
  DateTime startTime;
  DateTime endTime;

  Time(this.startTime, this.endTime);
}

enum Month { jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec }

enum WeekDay { mon, tue, wed, thu, fri, sat, sun }

List<Time> generateTimes({
  @required List<Month> months,
  @required List<WeekDay> weekDays,
  @required Time time,
  @required DateTime startDate,
  @required DateTime endDate,
}) {
  List<Time> times = [];

  /// iterate through each month
  for (int month = 0; month < months.length; month++) {
    /// iterate through each day
    for (int day = 0;
        day < daysInMonth(DateTime.now().year, month + 1);
        day++) {
      DateTime newTime =
          DateTime(DateTime.now().year, months[month].index + 1, day);

      /// iterate through each weekday
      for (int weekDay = 0; weekDay < weekDays.length; weekDay++) {
        /// check if weekday matches
        if (newTime.weekday == weekDays[weekDay].index + 1) {
          /// create startDateTime
          DateTime newStartDateTime = DateTime(
            newTime.year,
            newTime.month,
            newTime.day,
            time.startTime.hour,
            time.startTime.minute,
          );

          /// create endDateTime
          DateTime newEndDateTime = DateTime(
            newTime.year,
            newTime.month,
            newTime.day,
            time.endTime.hour,
            time.endTime.minute,
          );

          if ((newStartDateTime.isAfter(startDate) ||
                  newStartDateTime.isAtSameMomentAs(startDate)) &&
              (newEndDateTime.isBefore(endDate.add(Duration(days: 1))) ||
                  newEndDateTime
                      .isAtSameMomentAs(endDate.add(Duration(days: 1))))) {
            print(newStartDateTime);
            print(newEndDateTime);
            print('\n');
            times.add(Time(newStartDateTime, newEndDateTime));
          }
        }
      }
    }
  }

  return times;
}
