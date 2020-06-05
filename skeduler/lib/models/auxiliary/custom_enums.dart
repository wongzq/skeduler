import 'package:skeduler/models/auxiliary/preferences.dart';

enum MemberOption {
  makeOwner,
  makeAdmin,
  makeMember,
  edit,
  remove,
}

enum SubjectOption {
  edit,
  remove,
}

enum TimetableEditorOption {
  switchAxis,
  addSubject,
  addDummy,
  clearData,
  settings,
  save,
}

enum CustomOption {
  edit,
  reorder,
  remove,
}

enum AvailabilityOption {
  edit,
  remove,
}

enum ConflictOption {
  keep,
  unkeep,
  remove,
  editTimetable,
}

enum ConflictSort {
  date,
  member,
}

enum DrawerEnum {
  dashboard,
  group,
  members,
  subjects,
  timetables,
  schedules,
  settings,
  logout,
}

enum DisplaySize {
  small,
  medium,
  large,
}

displaySizeString(DisplaySize displaySize, Preferences preferences) {
  return displaySize == DisplaySize.small
      ? 'Small'
      : displaySize == DisplaySize.medium
          ? 'Medium'
          : displaySize == DisplaySize.large ? 'Large' : null;
}

enum Language {
  eng,
  chi,
}

languageString(Language language) {
  return language == Language.eng
      ? 'English'
      : language == Language.chi ? '中文' : null;
}
