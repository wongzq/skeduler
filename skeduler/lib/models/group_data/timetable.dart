import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeduler/models/group_data/time.dart';

class Timetable {
  /// Properties
  DateTime _startDate;
  DateTime _endDate;

  List<Weekday> _axisDays = [];
  List<Time> _axisTimes = [];
  List<String> _axisCustom = [];

  /// Constructor
  Timetable({
    Timestamp startDate,
    List<int> axisDays,
    List<Map<String, Timestamp>> axisTimes,
    List<String> axisCustom,
  }) {
    _startDate =
        DateTime.fromMillisecondsSinceEpoch(startDate.millisecondsSinceEpoch);
    _endDate =
        DateTime.fromMillisecondsSinceEpoch(endDate.millisecondsSinceEpoch);

    axisDays.forEach((val) {
      _axisDays.add(Weekday.values[val]);
    });

    axisTimes.forEach((val) {
      _axisTimes.add(Time(
        DateTime.fromMillisecondsSinceEpoch(
            val['startTime'].millisecondsSinceEpoch),
        DateTime.fromMillisecondsSinceEpoch(
            val['endTime'].millisecondsSinceEpoch),
      ));
    });

    axisCustom.forEach((val) {
      _axisCustom.add(val);
    });
  }

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  List<Weekday> get axisDays => _axisDays;
  List<Time> get axisTimes => _axisTimes;
  List<String> get axisCustom => _axisCustom;
}
