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
  /// show status of current editor
  CurrentEditor _currentEditor = CurrentEditor.month;

  /// height values for display
  double _monthEditorHeight;
  double _dayEditorHeight;
  double _timeEditorHeight;

  /// height values when the editors are selected
  double _monthEditorSelectedHeight;
  double _dayEditorSelectedHeight;
  double _timeEditorSelectedHeight;

  /// general values of the editors
  double _totalHeight;
  double _totalWidth;
  double _dividerHeight;
  double _defaultPrimaryHeight;
  double _defaultSecondaryHeight;
  final Duration _duration = Duration(milliseconds: 500);
  final Curve _curve = Curves.easeOutCubic;

  /// constructor
  EditorsStatus({
    CurrentEditor currentEditor,
    double monthEditorHeight,
    double dayEditorHeight,
    double timeEditorHeight,
    double monthEditorSelectedHeight,
    double dayEditorSelectedHeight,
    double timeEditorSelectedHeight,
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

    _monthEditorSelectedHeight = monthEditorSelectedHeight;
    _dayEditorSelectedHeight = dayEditorSelectedHeight;
    _timeEditorSelectedHeight = timeEditorSelectedHeight;

    _totalHeight = totalHeight;
    _totalWidth = totalWidth;
    _dividerHeight = dividerHeight;
    _defaultPrimaryHeight = defaultPrimaryHeight;
    _defaultSecondaryHeight = defaultSecondaryHeight;
  }

  /// methods
  /// getter methods
  CurrentEditor get currentEditor => _currentEditor;
  double get totalHeight => _totalHeight;
  double get totalWidth => _totalWidth;
  double get dividerHeight => _dividerHeight;
  double get defaultPrimaryHeight => _defaultPrimaryHeight;
  double get defaultSecondaryHeight => _defaultSecondaryHeight;

  double get monthEditorHeight => _monthEditorHeight;
  double get dayEditorHeight => _dayEditorHeight;
  double get timeEditorHeight => _timeEditorHeight;
  double get monthEditorSelectedHeight => _monthEditorSelectedHeight;
  double get dayEditorSelectedHeight => _dayEditorSelectedHeight;
  double get timeEditorSelectedHeight => _timeEditorSelectedHeight;

  Duration get duration => _duration;
  Curve get curve => _curve;

  /// setter methods
  set currentEditor(CurrentEditor value) {
    _currentEditor = value;
    if (value == CurrentEditor.month || value == CurrentEditor.monthSelected) {
      _switchToMonthEditor();
    } else if (value == CurrentEditor.day ||
        value == CurrentEditor.daySelected) {
      _switchToDayEditor();
    } else if (value == CurrentEditor.time) {
      _switchToTimeEditor();
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

  set monthEditorSelectedHeight(double value) {
    _monthEditorSelectedHeight = value;
    notifyListeners();
  }

  set dayEditorSelectedHeight(double value) {
    _dayEditorSelectedHeight = value;
    notifyListeners();
  }

  set timeEditorSelectedHeight(double value) {
    _timeEditorSelectedHeight = value;
    notifyListeners();
  }

  /// class methods
  void _switchToMonthEditor() {
    _dayEditorHeight = _defaultSecondaryHeight;
    _timeEditorHeight = _defaultSecondaryHeight;
    _monthEditorHeight = _totalHeight -
        2 * _dividerHeight -
        _dayEditorHeight -
        _timeEditorHeight;

    notifyListeners();
  }

  void _switchToDayEditor() {
    _monthEditorHeight = _monthEditorSelectedHeight ?? _defaultSecondaryHeight;
    _timeEditorHeight = _defaultSecondaryHeight;
    _dayEditorHeight = _totalHeight -
        2 * _dividerHeight -
        _monthEditorHeight -
        _timeEditorHeight;

    notifyListeners();
  }

  void _switchToTimeEditor() {
    _monthEditorHeight = _monthEditorSelectedHeight ?? _defaultSecondaryHeight;
    _dayEditorHeight = _dayEditorSelectedHeight ?? _defaultSecondaryHeight;
    _timeEditorHeight = _timeEditorSelectedHeight;

    notifyListeners();
  }
}
