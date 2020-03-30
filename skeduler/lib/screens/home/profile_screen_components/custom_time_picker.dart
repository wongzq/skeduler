import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CustomTimePicker extends CommonPickerModel {
  /// properties
  int interval = 1;

  /// methods
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  CustomTimePicker({DateTime currentTime, LocaleType locale, this.interval = 1})
      : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();
    this.setLeftIndex((this.currentTime.hour) % 12);
    this.setMiddleIndex(this.currentTime.minute ~/ interval);
    this.setRightIndex(this.currentTime.hour < 12 ? 0 : 1);
    _fillLeftList();
    _fillMiddleList();
    _fillRightList();
  }

  @override
  String leftStringAtIndex(int index) {
    if (index >= 0 && index < 12) {
      return this.digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String middleStringAtIndex(int index) {
    if (index >= 0 && index < 60 / interval) {
      return this.digits(index * interval, 2);
    } else {
      return null;
    }
  }

  @override
  String rightStringAtIndex(int index) {
    if (index == 0) {
      return 'AM';
    } else if (index == 1) {
      return 'PM';
    }
    return null;
  }

  void _fillLeftList() {
    this.leftList = List.generate(12, (int index) {
      return '$index';
    });
  }

  void _fillMiddleList() {
    this.middleList = List.generate(60 ~/ interval, (int index) {
      index *= interval;
      return '$index';
    });
  }

  void _fillRightList() {
    this.rightList = List.generate(2, (int index) {
      return '$index';
    });
  }

  @override
  void setLeftIndex(int index) {
    super.setLeftIndex(index);
    _fillLeftList();
  }

  @override
  void setMiddleIndex(int index) {
    super.setMiddleIndex(index);
    _fillMiddleList();
  }

  @override
  void setRightIndex(int index) {
    super.setRightIndex(index);
    _fillRightList();
  }

  @override
  String leftDivider() {
    return ":";
  }

  @override
  String rightDivider() {
    return " ";
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 1];
  }

  @override
  DateTime finalTime() {
    int hour = super.currentLeftIndex() + 12 * super.currentRightIndex();
    return currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            hour,
            this.currentMiddleIndex() * interval,
            0,
          )
        : DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            hour,
            this.currentMiddleIndex() * interval,
            0,
          );
  }
}
