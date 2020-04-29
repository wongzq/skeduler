import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/home_drawer.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/subject.dart';
import 'package:skeduler/screens/home/subjects_screen_components/subject_list_tile.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';

class SubjectsScreen extends StatefulWidget {
  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  GroupStatus _groupStatus;

  bool _isUpdating = false;
  List<Subject> _tempSubjects = [];

  List<Widget> _generateSubjects() {
    List<Widget> widgets = [];

    if (_isUpdating) {
      _tempSubjects = _tempSubjects ?? [];
      _tempSubjects.forEach((subject) {
        widgets.add(SubjectListTile(
          key: UniqueKey(),
          subject: subject,
          valSetIsUpdating: (value) {
            setState(() {
              _tempSubjects =
                  value ? List.from(_groupStatus.group.subjects) : [];
              if (value == false) _groupStatus.hasChanges = false;
              _isUpdating = value;
            });
          },
        ));
      });
    } else {
      _groupStatus.group.subjects.forEach((subject) {
        widgets.add(SubjectListTile(
          key: UniqueKey(),
          subject: subject,
          valSetIsUpdating: (value) {
            setState(() {
              _tempSubjects =
                  value ? List.from(_groupStatus.group.subjects) : [];
              if (value == false) _groupStatus.hasChanges = false;
              _isUpdating = value;
            });
          },
        ));
      });
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    _groupStatus = Provider.of<GroupStatus>(context);

    return _groupStatus.group == null
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: _groupStatus.group.name == null
                  ? Text(
                      'Subjects',
                      style: textStyleAppBarTitle,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _groupStatus.group.name,
                          style: textStyleAppBarTitle,
                        ),
                        Text(
                          'Subjects',
                          style: textStyleBody,
                        ),
                      ],
                    ),
            ),
            drawer: HomeDrawer(DrawerEnum.subjects),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Visibility(
                  visible: _groupStatus.hasChanges,
                  child: FloatingActionButton(
                    heroTag: 'Subjects Save',
                    foregroundColor: getFABIconForegroundColor(context),
                    backgroundColor: getFABIconBackgroundColor(context),
                    child: Icon(Icons.save),
                    onPressed: () async {
                      setState(() {
                        _isUpdating = true;
                        _tempSubjects = List.from(_groupStatus.group.subjects);
                      });
                      if (await dbService.updateGroupSubjects(
                          _groupStatus.group.docId,
                          _groupStatus.group.subjects)) {
                        _groupStatus.hasChanges = false;
                        Fluttertoast.showToast(
                          msg: 'Successfully updated subjects',
                          toastLength: Toast.LENGTH_LONG,
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Failed to update subjects',
                          toastLength: Toast.LENGTH_LONG,
                        );
                      }
                      setState(() {
                        _isUpdating = false;
                        _tempSubjects = [];
                      });
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                FloatingActionButton(
                  heroTag: 'Subjects Add',
                  foregroundColor: getFABIconForegroundColor(context),
                  backgroundColor: getFABIconBackgroundColor(context),
                  child: Icon(Icons.add),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        GlobalKey<FormState> formKey = GlobalKey<FormState>();
                        String newSubjectName;
                        String newSubjectNickname;

                        return AlertDialog(
                          title: Text(
                            'New subject',
                            style: TextStyle(fontSize: 16.0),
                          ),
                          content: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'Subject short form (optional)',
                                    hintStyle: TextStyle(
                                      fontSize: 15.0,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      newSubjectNickname = value.trim(),
                                  validator: (value) => null,
                                ),
                                TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'Subject full name',
                                    hintStyle: TextStyle(
                                      fontSize: 15.0,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  onChanged: (value) =>
                                      newSubjectName = value.trim(),
                                  validator: (value) =>
                                      value == null || value.trim() == ''
                                          ? 'Subject name cannot be empty'
                                          : null,
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('CANCEL'),
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                            FlatButton(
                              child: Text('SAVE'),
                              onPressed: () async {
                                if (formKey.currentState.validate()) {
                                  Navigator.of(context).maybePop();

                                  _tempSubjects =
                                      List.from(_groupStatus.group.subjects);

                                  setState(() => _isUpdating = true);

                                  await dbService
                                      .updateGroupSubjects(
                                    _groupStatus.group.docId,
                                    _groupStatus.group.subjects,
                                  )
                                      .then((value) async {
                                    if (value) {
                                      _groupStatus.group.subjects.add(Subject(
                                        name: newSubjectName,
                                        nickname: newSubjectNickname,
                                      ));

                                      String returnMsg =
                                          await dbService.addGroupSubject(
                                              _groupStatus.group.docId,
                                              Subject(
                                                name: newSubjectName,
                                                nickname: newSubjectNickname,
                                              ));

                                      setState(() {
                                        _isUpdating = false;
                                        _groupStatus.hasChanges = false;
                                      });
                                      Fluttertoast.showToast(
                                        msg: returnMsg,
                                        toastLength: Toast.LENGTH_LONG,
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: 'Failed to update subjects',
                                        toastLength: Toast.LENGTH_LONG,
                                      );
                                    }
                                  });
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            body: ReorderableListView(
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  Subject subject = _groupStatus.group.subjects[oldIndex];
                  _groupStatus.group.subjects.removeAt(oldIndex);

                  if (newIndex >= _groupStatus.group.subjects.length) {
                    _groupStatus.group.subjects.add(subject);
                  } else {
                    _groupStatus.group.subjects.insert(newIndex, subject);
                  }

                  _groupStatus.hasChanges = true;
                });
              },
              children: _generateSubjects(),
            ),
          );
  }
}
