// abstract class [GridData]
abstract class GridData {
  String _display;
}

// [GridDataSubject] class
class GridDataSubject extends GridData {
  GridDataSubject({String display}) {
    super._display = display;
  }

  String get display => super._display;
  set display(String value) => super._display = value;
}

// [GridDataMember] class
class GridDataMember extends GridData {
  GridDataMember({String display}) {
    super._display = display;
  }

  String get display => super._display;
  set display(String value) => super._display = value;
}

// [GridDataSubjectMember] class
class GridDataSubjectMember extends GridData {
  // properties
  GridDataSubject _subject;
  GridDataMember _member;

  // constructors
  GridDataSubjectMember({
    String subject,
    String member,
  }) {
    this._subject = GridDataSubject(display: subject);
    this._member = GridDataMember(display: member);
    super._display = _getDisplay();
  }

  // getter methods
  String get subject => this._display;
  String get member => this._member.display;

  // setter methods
  set subject(String display) {
    this._subject.display = display;
    super._display = _getDisplay();
  }

  set member(String display) {
    this._member.display = display;
    super._display = _getDisplay();
  }

  // auxiliary methods
  String _getDisplay() => '${_subject.display} : ${_member.display}';
}
