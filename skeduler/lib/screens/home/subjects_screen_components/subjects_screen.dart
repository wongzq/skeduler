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
  ValueNotifier<Group> _group;

  bool _reordered = false;
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
          reordered: _reordered,
          valSetIsUpdating: (value) {
            setState(() {
              _tempSubjects = value ? List.from(_group.value.subjects) : [];
              if (value == false) _reordered = false;
              return _isUpdating = value;
            });
          },
        ));
      });
    } else {
      _group.value.subjects.forEach((subject) {
        widgets.add(SubjectListTile(
          key: UniqueKey(),
          subject: subject,
          reordered: _reordered,
          valSetIsUpdating: (value) {
            setState(() {
              _tempSubjects = value ? List.from(_group.value.subjects) : [];
              if (value == false) _reordered = false;
              return _isUpdating = value;
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
    _group = Provider.of<ValueNotifier<Group>>(context);

    return _group.value == null
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: _group.value.name == null
                  ? Text(
                      'Subjects',
                      style: textStyleAppBarTitle,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _group.value.name,
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
                  visible: _reordered,
                  child: FloatingActionButton(
                    foregroundColor: getFABIconForegroundColor(context),
                    backgroundColor: getFABIconBackgroundColor(context),
                    child: Icon(Icons.save),
                    onPressed: () async {
                      setState(() {
                        _isUpdating = true;
                        _tempSubjects = List.from(_group.value.subjects);
                      });
                      if (await dbService.updateGroupSubjects(
                          _group.value.docId, _group.value.subjects)) {
                        _reordered = false;
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

                                  if (_reordered) {
                                    _tempSubjects =
                                        List.from(_group.value.subjects);
                                    setState(() => _isUpdating = true);

                                    _group.value.subjects.add(Subject(
                                      name: newSubjectName,
                                      nickname: newSubjectNickname,
                                    ));

                                    await dbService.updateGroupSubjects(
                                      _group.value.docId,
                                      _group.value.subjects,
                                    );

                                    setState(() {
                                      _isUpdating = false;
                                      _reordered = false;
                                    });
                                  }

                                  String returnMsg =
                                      await dbService.addGroupSubject(
                                          _group.value.docId,
                                          Subject(
                                            name: newSubjectName,
                                            nickname: newSubjectNickname,
                                          ));

                                  Fluttertoast.showToast(
                                    msg: returnMsg,
                                    toastLength: Toast.LENGTH_LONG,
                                  );
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
                  Subject subject = _group.value.subjects[oldIndex];
                  _group.value.subjects.removeAt(oldIndex);

                  if (newIndex >= _group.value.subjects.length) {
                    _group.value.subjects.add(subject);
                  } else {
                    _group.value.subjects.insert(newIndex, subject);
                  }

                  _reordered = true;
                });
              },
              children: _generateSubjects(),
            ),
          );
  }
}
