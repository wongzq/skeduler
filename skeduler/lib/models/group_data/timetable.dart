import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:skeduler/models/auxiliary/timetable_grid_models.dart';
import 'package:skeduler/models/group_data/time.dart';

// --------------------------------------------------------------------------------
// TimetableMetadata class
// --------------------------------------------------------------------------------

class TimetableMetadata {
  // properties
  String docId;
  Timestamp startDate;
  Timestamp endDate;

  // constructors
  TimetableMetadata({
    this.docId,
    this.startDate,
    this.endDate,
  });

  // getter methods
  Map<String, dynamic> get asMap {
    return {
      'docId': this.docId,
      'startDate': this.startDate,
      'endDate': this.endDate,
    };
  }
}

// --------------------------------------------------------------------------------
// Timetable class
// --------------------------------------------------------------------------------

class Timetable {
  // properties
  String _docId;
  DateTime _startDate;
  DateTime _endDate;

  GridAxis _gridAxisOfDay;
  GridAxis _gridAxisOfTime;
  GridAxis _gridAxisOfCustom;

  List<Weekday> _axisDay = [];
  List<Time> _axisTime = [];
  List<String> _axisCustom = [];

  TimetableGridDataList _gridDataList = TimetableGridDataList();

  // constructors
  Timetable({
    @required String docId,
    Timestamp startDate,
    Timestamp endDate,
    GridAxis gridAxisOfDay,
    GridAxis gridAxisOfTime,
    GridAxis gridAxisOfCustom,
    List<Weekday> axisDay,
    List<Time> axisTime,
    List<String> axisCustom,
    TimetableGridDataList gridDataList,
  }) {
    // documentID
    this._docId = docId;

    // timetable start date
    if (startDate != null)
      this._startDate =
          DateTime.fromMillisecondsSinceEpoch(startDate.millisecondsSinceEpoch);

    // timetable end date
    if (endDate != null)
      this._endDate =
          DateTime.fromMillisecondsSinceEpoch(endDate.millisecondsSinceEpoch);

    // timetable days axis
    if (gridAxisOfDay != null) this._gridAxisOfDay = gridAxisOfDay;
    if (axisDay != null) this._axisDay = List<Weekday>.from(axisDay ?? []);

    // timetable times axis
    if (gridAxisOfTime != null) this._gridAxisOfTime = gridAxisOfTime;
    if (axisTime != null) this._axisTime = List<Time>.from(axisTime ?? []);

    // timetable custom axis
    if (gridAxisOfCustom != null) this._gridAxisOfCustom = gridAxisOfCustom;
    if (axisCustom != null)
      this._axisCustom = List<String>.from(axisCustom ?? []);

    if (gridDataList != null)
      this._gridDataList =
          TimetableGridDataList.from(gridDataList ?? TimetableGridDataList());
  }

  // getter methods
  String get docId => this._docId;
  DateTime get startDate => this._startDate;
  DateTime get endDate => this._endDate;
  GridAxis get gridAxisOfDay => this._gridAxisOfDay;
  GridAxis get gridAxisOfTime => this._gridAxisOfTime;
  GridAxis get gridAxisOfCustom => this._gridAxisOfCustom;
  List<Weekday> get axisDay => this._axisDay;
  List<Time> get axisTime => this._axisTime;
  List<String> get axisCustom => this._axisCustom;
  TimetableGridDataList get gridDataList => this._gridDataList;

  // get list as [List<String>]
  List<String> get axisDayStr => List.generate(
      this._axisDay.length, (index) => getWeekdayStr(this._axisDay[index]));
  List<String> get axisDayShortStr => List.generate(this._axisDay.length,
      (index) => getWeekdayShortStr(this._axisDay[index]));
  List<String> get axisTimeStr => List.generate(
      this._axisTime.length, (index) => getTimeStr(this._axisTime[index]));

  bool get isValid => this._docId != null &&
          this._docId.trim() != '' &&
          this._startDate != null &&
          this._endDate != null
      ? true
      : false;
}

// --------------------------------------------------------------------------------
// EditTimetable class
// --------------------------------------------------------------------------------

class EditTimetable extends ChangeNotifier {
  // properties
  String _docId;
  DateTime _startDate;
  DateTime _endDate;

  GridAxis _gridAxisOfDay;
  GridAxis _gridAxisOfTime;
  GridAxis _gridAxisOfCustom;

  List<Weekday> _axisDay;
  List<Time> _axisTime;
  List<String> _axisCustom;

  TimetableGridDataList _gridDataList;

  // constructors
  EditTimetable({
    String docId,
    DateTime startDate,
    DateTime endDate,
    GridAxis gridAxisOfDay,
    GridAxis gridAxisOfTime,
    GridAxis gridAxisOfCustom,
    List<Weekday> axisDay,
    List<Time> axisTime,
    List<String> axisCustom,
    TimetableGridDataList gridDataList,
  })  : this._docId = docId,
        this._startDate = startDate,
        this._endDate = endDate,
        this._gridAxisOfDay = gridAxisOfDay ?? GridAxis.x,
        this._gridAxisOfTime = gridAxisOfTime ?? GridAxis.y,
        this._gridAxisOfCustom = gridAxisOfCustom ?? GridAxis.z,
        this._axisDay = List<Weekday>.from(axisDay ?? []),
        this._axisTime = List<Time>.from(axisTime ?? []),
        this._axisCustom = List<String>.from(axisCustom ?? []),
        this._gridDataList =
            TimetableGridDataList.from(gridDataList ?? TimetableGridDataList());

  EditTimetable.fromTimetable(Timetable ttb)
      : this(
          docId: ttb.docId,
          startDate: ttb.startDate,
          endDate: ttb.endDate,
          gridAxisOfDay: ttb.gridAxisOfDay,
          gridAxisOfTime: ttb.gridAxisOfTime,
          gridAxisOfCustom: ttb.gridAxisOfCustom,
          axisDay: ttb.axisDay,
          axisTime: ttb.axisTime,
          axisCustom: ttb.axisCustom,
          gridDataList: ttb.gridDataList,
        );

  EditTimetable.copy(EditTimetable editTtb)
      : this(
          docId: editTtb.docId,
          startDate: editTtb.startDate,
          endDate: editTtb.endDate,
          gridAxisOfDay: editTtb.gridAxisOfDay,
          gridAxisOfTime: editTtb.gridAxisOfTime,
          gridAxisOfCustom: editTtb.gridAxisOfCustom,
          axisDay: editTtb.axisDay,
          axisTime: editTtb.axisTime,
          axisCustom: editTtb.axisCustom,
          gridDataList: editTtb.gridDataList,
        );

  // getter methods
  String get docId => this._docId;
  DateTime get startDate => this._startDate;
  DateTime get endDate => this._endDate;
  GridAxis get gridAxisOfDay => this._gridAxisOfDay;
  GridAxis get gridAxisOfTime => this._gridAxisOfTime;
  GridAxis get gridAxisOfCustom => this._gridAxisOfCustom;
  List<Weekday> get axisDay => this._axisDay;
  List<Time> get axisTime => this._axisTime;
  List<String> get axisCustom => this._axisCustom;
  TimetableGridDataList get gridDataList => this._gridDataList;
  TimetableMetadata get metadata => TimetableMetadata(
        docId: this._docId,
        startDate: Timestamp.fromDate(this._startDate),
        endDate: Timestamp.fromDate(this._endDate),
      );

  bool get isValid => this._docId != null &&
          this._docId.trim() != '' &&
          this._startDate != null &&
          this._endDate != null
      ? true
      : false;

  // get list as [List<String>]
  List<String> get axisDayStr =>
      List.generate(_axisDay.length, (index) => getWeekdayStr(_axisDay[index]));
  List<String> get axisDayShortStr => List.generate(
      _axisDay.length, (index) => getWeekdayShortStr(_axisDay[index]));
  List<String> get axisTimeStr =>
      List.generate(_axisTime.length, (index) => getTimeStr(_axisTime[index]));

  // setter methods
  set docId(String docId) {
    this._docId = docId;
    notifyListeners();
  }

  set startDate(DateTime startDate) {
    this._startDate = startDate;
    notifyListeners();
  }

  set endDate(DateTime endDate) {
    this._endDate = endDate;
    notifyListeners();
  }

  set gridAxisOfDay(GridAxis gridAxis) {
    this._gridAxisOfDay = gridAxis;
    notifyListeners();
  }

  set gridAxisOfTime(GridAxis gridAxis) {
    this._gridAxisOfTime = gridAxis;
    notifyListeners();
  }

  set gridAxisOfCustom(GridAxis gridAxis) {
    this._gridAxisOfCustom = gridAxis;
    notifyListeners();
  }

  set axisDay(List<Weekday> axisDay) {
    this._axisDay = axisDay;
    this._axisDay.sort((a, b) => a.index.compareTo(b.index));
    notifyListeners();
  }

  set axisTime(List<Time> axisTime) {
    this._axisTime = axisTime;
    this._axisTime.sort((a, b) => a.startTime.compareTo(b.startTime));
    notifyListeners();
  }

  set axisCustom(List<String> axisCustom) {
    this._axisCustom = axisCustom;
    notifyListeners();
  }

  set gridDataList(TimetableGridDataList gridDataList) {
    this._gridDataList = gridDataList;
    notifyListeners();
  }

  void updateTimetableSettings({
    String docId,
    DateTime startDate,
    DateTime endDate,
    List<Weekday> axisDay,
    List<Time> axisTime,
    List<String> axisCustom,
    TimetableGridDataList gridDataList,
  }) {
    this.docId = docId ?? this.docId;
    this.startDate = startDate ?? this.startDate;
    this.endDate = endDate ?? this.endDate;
    this.axisDay = axisDay ?? this.axisDay;
    this.axisTime = axisTime ?? this.axisTime;
    this.axisCustom = axisCustom ?? this.axisCustom;
    notifyListeners();
  }

  void updateTimetableFromCopy(Timetable ttb) {
    this._gridAxisOfDay = ttb.gridAxisOfDay;
    this._gridAxisOfTime = ttb.gridAxisOfTime;
    this._gridAxisOfCustom = ttb.gridAxisOfCustom;
    this._axisDay = ttb.axisDay;
    this._axisTime = ttb.axisTime;
    this._axisCustom = ttb.axisCustom;
    this._gridDataList = ttb.gridDataList;
    notifyListeners();
  }

  void updateTimetableFromCopyAxes(Timetable ttb) {
    this._gridAxisOfDay = ttb.gridAxisOfDay;
    this._gridAxisOfTime = ttb.gridAxisOfTime;
    this._gridAxisOfCustom = ttb.gridAxisOfCustom;
    this._axisDay = ttb.axisDay;
    this._axisTime = ttb.axisTime;
    this._axisCustom = ttb.axisCustom;
    this._gridDataList = TimetableGridDataList();
    notifyListeners();
  }
}

// --------------------------------------------------------------------------------
// Auxiliary functions
// --------------------------------------------------------------------------------

// check if all [Timetable] in [List<Timetable>] is consecutive with no conflicts of date
bool isConsecutiveTimetables(List<TimetableMetadata> ttbMetadatas) {
  bool isConsecutive = true;

  // sort the area in terms of startDate
  ttbMetadatas.sort((a, b) {
    return a.startDate.compareTo(b.startDate);
  });

  // loop through the array to find any date conflict
  for (int i = 0; i < ttbMetadatas.length; i++) {
    if (i != 0) {
      // if conflict is found, sets [isConsecutive] as [false]
      if (!(ttbMetadatas[i - 1]
              .startDate
              .toDate()
              .isBefore(ttbMetadatas[i].startDate.toDate()) &&
          ttbMetadatas[i - 1]
              .endDate
              .toDate()
              .isBefore(ttbMetadatas[i].endDate.toDate()) &&
          (ttbMetadatas[i - 1]
                  .endDate
                  .toDate()
                  .isBefore(ttbMetadatas[i].startDate.toDate()) ||
              ttbMetadatas[i - 1]
                  .endDate
                  .toDate()
                  .isAtSameMomentAs(ttbMetadatas[i].startDate.toDate())))) {
        isConsecutive = false;
        break;
      }
    }
  }

  return isConsecutive;
}

// convert from [EditTimetable] to Firestore's [Map<String, dynamic>] format
Map<String, dynamic> firestoreMapFromEditTimetable(EditTimetable editTtb) {
  Map<String, dynamic> firestoreMap = {};

  // convert startDate and endDate
  firestoreMap['startDate'] = Timestamp.fromDate(editTtb.startDate);
  firestoreMap['endDate'] = Timestamp.fromDate(editTtb.endDate);

  // convert gridAxisTypes
  if (editTtb.gridAxisOfDay == null ||
      editTtb.gridAxisOfTime == null ||
      editTtb.gridAxisOfCustom == null) {
    firestoreMap['gridAxisOfDay'] = GridAxis.x.index;
    firestoreMap['gridAxisOfTime'] = GridAxis.y.index;
    firestoreMap['gridAxisOfCustom'] = GridAxis.z.index;
  } else {
    List<GridAxis> gridAxisTypes = [
      editTtb.gridAxisOfDay,
      editTtb.gridAxisOfTime,
      editTtb.gridAxisOfCustom,
    ];

    if (gridAxisTypes.contains(GridAxis.x) &&
        gridAxisTypes.contains(GridAxis.y) &&
        gridAxisTypes.contains(GridAxis.z)) {
      firestoreMap['gridAxisOfDay'] = editTtb.gridAxisOfDay.index;
      firestoreMap['gridAxisOfTime'] = editTtb.gridAxisOfTime.index;
      firestoreMap['gridAxisOfCustom'] = editTtb.gridAxisOfCustom.index;
    } else {
      firestoreMap['gridAxisOfDay'] = GridAxis.x.index;
      firestoreMap['gridAxisOfTime'] = GridAxis.y.index;
      firestoreMap['gridAxisOfCustom'] = GridAxis.z.index;
    }
  }

  // convert axisDay
  if (editTtb.axisDay != null) {
    List<int> axisDaysInt = [];
    editTtb.axisDay.forEach((weekday) => axisDaysInt.add(weekday.index));
    axisDaysInt.sort((a, b) => a.compareTo(b));
    firestoreMap['axisDay'] = axisDaysInt;
  }

  // convert axisTime
  if (editTtb.axisTime != null) {
    List<Map<String, Timestamp>> axisTimesTimestamps = [];
    editTtb.axisTime.forEach((time) {
      axisTimesTimestamps.add({
        'startTime': Timestamp.fromDate(time.startTime),
        'endTime': Timestamp.fromDate(time.endTime),
      });
    });
    axisTimesTimestamps
        .sort((a, b) => a['startTime'].compareTo(b['startTime']));
    firestoreMap['axisTime'] = axisTimesTimestamps;
  }

  // convert axisCustom
  if (editTtb.axisCustom != null) {
    firestoreMap['axisCustom'] = editTtb.axisCustom;
  }

  // convert gridDataList
  if (editTtb.gridDataList != null) {
    List<Map<String, dynamic>> gridDataList = [];

    editTtb.gridDataList.value.forEach((gridData) {
      if (editTtb.axisDay.contains(gridData.coord.day) &&
          editTtb.axisTime.contains(gridData.coord.time) &&
          editTtb.axisCustom.contains(gridData.coord.custom)) {
        // convert coords
        Map<String, dynamic> coord = {
          'day': gridData.coord.day.index,
          'time': {
            'startTime': Timestamp.fromDate(gridData.coord.time.startTime),
            'endTime': Timestamp.fromDate(gridData.coord.time.endTime),
          },
          'custom': gridData.coord.custom,
        };

        // convert subject
        String subject = gridData.dragData.subject.display;

        // convert member
        String member = gridData.dragData.member.display;

        // add to list
        gridDataList.add({
          'coord': coord,
          'subject': subject,
          'member': member,
        });
      }
    });

    firestoreMap['gridDataList'] = gridDataList;
  }

  // return final map in firestore format
  return firestoreMap;
}
