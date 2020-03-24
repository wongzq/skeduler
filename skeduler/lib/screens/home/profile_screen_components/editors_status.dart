import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum CurrentEditor {
  month,
  day,
  time,
  monthSelected,
  daySelected,
}

class EditorsStatus extends ChangeNotifier {
  //properties
  // show status of current editor
  CurrentEditor _currentEditor = CurrentEditor.month;

  // height values for display
  double _monthEditorHeight;
  double _dayEditorHeight;
  double _timeEditorHeight;

  // height values when the editors are collapsed
  double _monthEditorCollapsedHeight;
  double _dayEditorCollapsedHeight;
  double _timeEditorCollapsedHeight;

  // general values of the editors
  double _totalHeight;
  double _totalWidth;
  double _dividerHeight;
  double _defaultPrimaryHeight;
  double _defaultSecondaryHeight;

  // constructor
  EditorsStatus({
    CurrentEditor currentEditor,
    double monthEditorHeight,
    double dayEditorHeight,
    double timeEditorHeight,
    double monthEditorCollapsedHeight,
    double dayEditorCollapsedHeight,
    double timeEditorCollapsedHeight,
    double totalHeight,
    double totalWidth,
    double dividerHeight,
    double defaultPrimaryHeight,
    double defaultSecondaryHeight,
  }) {
    _currentEditor = currentEditor;

    _monthEditorHeight = monthEditorHeight;
    _dayEditorHeight = dayEditorHeight;
    _timeEditorHeight = timeEditorHeight;

    _monthEditorCollapsedHeight = monthEditorCollapsedHeight;
    _dayEditorCollapsedHeight = dayEditorCollapsedHeight;
    _timeEditorCollapsedHeight = timeEditorCollapsedHeight;

    _totalHeight = totalHeight;
    _totalWidth = totalWidth;
    _dividerHeight = dividerHeight;
    _defaultPrimaryHeight = defaultPrimaryHeight;
    _defaultSecondaryHeight = defaultSecondaryHeight;
  }

  // methods
  // getter methods
  CurrentEditor get currentEditor => _currentEditor;
  double get totalHeight => _totalHeight;
  double get totalWidth => _totalWidth;
  double get dividerHeight => _dividerHeight;
  double get defaultPrimaryHeight => _defaultPrimaryHeight;
  double get defaultSecondaryHeight => _defaultSecondaryHeight;

  double get monthEditorHeight => _monthEditorHeight;
  double get dayEditorHeight => _dayEditorHeight;
  double get timeEditorHeight => _timeEditorHeight;
  double get monthEditorCollapsedHeight => _monthEditorCollapsedHeight;
  double get dayEditorCollapsedHeight => _dayEditorCollapsedHeight;
  double get timeEditorCollapsedHeight => _timeEditorCollapsedHeight;

  // setter methods
  set currentEditor(CurrentEditor value) {
    _currentEditor = value;
    if (value == CurrentEditor.month || value == CurrentEditor.monthSelected) {
      switchToMonthEditor();
    } else if (value == CurrentEditor.day ||
        value == CurrentEditor.daySelected) {
      switchToDayEditor();
    } else if (value == CurrentEditor.time) {
      switchToTimeEditor();
    }
    notifyListeners();
  }

  set totalHeight(double value) {
    _totalHeight = value;
    notifyListeners();
  }

  set totalWidth(double value) {
    _totalWidth = value;
    notifyListeners();
  }

  set dividerHeight(double value) {
    _dividerHeight = value;
    notifyListeners();
  }

  set defaultPrimaryHeight(double value) {
    _defaultPrimaryHeight = value;
    notifyListeners();
  }

  set defaultSecondaryHeight(double value) {
    _defaultSecondaryHeight = value;
    notifyListeners();
  }

  set monthEditorHeight(double value) {
    _monthEditorHeight = value;
    notifyListeners();
  }

  set dayEditorHeight(double value) {
    _dayEditorHeight = value;
    notifyListeners();
  }

  set timeEditorHeight(double value) {
    _timeEditorHeight = value;
    notifyListeners();
  }

  set monthEditorCollapsedHeight(double value) {
    _monthEditorCollapsedHeight = value;
    notifyListeners();
  }

  set dayEditorCollapsedHeight(double value) {
    _dayEditorCollapsedHeight = value;
    notifyListeners();
  }

  set timeEditorCollapsedHeight(double value) {
    _timeEditorCollapsedHeight = value;
    notifyListeners();
  }

  // class methods
  void switchToMonthEditor() {
    _dayEditorHeight = _defaultSecondaryHeight;
    _timeEditorHeight = _defaultSecondaryHeight;
    _monthEditorHeight = _totalHeight -
        2 * _dividerHeight -
        _dayEditorHeight -
        _timeEditorHeight;

    notifyListeners();
  }

  void switchToDayEditor() {
    _monthEditorHeight = _monthEditorCollapsedHeight ?? _defaultSecondaryHeight;
    _timeEditorHeight = _defaultSecondaryHeight;
    _dayEditorHeight = _totalHeight -
        2 * _dividerHeight -
        _monthEditorHeight -
        _timeEditorHeight;

    notifyListeners();
  }

  void switchToTimeEditor() {
    _monthEditorHeight = _monthEditorCollapsedHeight ?? _defaultSecondaryHeight;
    _dayEditorHeight = _defaultSecondaryHeight;
    _timeEditorHeight = _totalHeight -
        2 * _dividerHeight -
        _monthEditorHeight -
        _dayEditorHeight;

    notifyListeners();
  }
}
