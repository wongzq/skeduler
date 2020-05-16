import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/home_drawer.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/screens/home/subjects_screen_components/subject_list_tile.dart';
import 'package:skeduler/shared/components/add_subject_dialog.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';

class SubjectsScreen extends StatefulWidget {
  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  DatabaseService _dbService;
  GroupStatus _groupStatus;

  bool _orderChanged;
  List<String> _tempSubjectMetadatas;

  List<Widget> _generateSubjects() {
    List<Widget> widgets = [];

    if (_orderChanged) {
      GroupStatus.reorderSubjects(
        subjects: _groupStatus.subjects,
        subjectMetadatas: _tempSubjectMetadatas,
      ).forEach((subject) {
        widgets.add(SubjectListTile(
          key: UniqueKey(),
          subject: subject,
        ));
      });
    } else {
      _groupStatus.subjects.forEach((subject) {
        widgets.add(SubjectListTile(
          key: UniqueKey(),
          subject: subject,
        ));
      });
    }

    return widgets;
  }

  @override
  void initState() {
    _orderChanged = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _dbService = Provider.of<DatabaseService>(context);
    _groupStatus = Provider.of<GroupStatus>(context);

    _tempSubjectMetadatas = () {
      bool renewSubjectMetadatas = false;

      if (_tempSubjectMetadatas == null) {
        renewSubjectMetadatas = true;
      } else {
        _groupStatus.group.subjectMetadatas.forEach((subjectMetadata) {
          if (!_tempSubjectMetadatas.contains(subjectMetadata)) {
            renewSubjectMetadatas = true;
          }
        });

        _tempSubjectMetadatas.forEach((subjectMetadata) {
          if (!_groupStatus.group.subjectMetadatas.contains(subjectMetadata)) {
            renewSubjectMetadatas = true;
          }
        });
      }

      return renewSubjectMetadatas
          ? List<String>.from(_groupStatus.group.subjectMetadatas)
          : _tempSubjectMetadatas;
    }();

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
                  visible: _orderChanged,
                  child: FloatingActionButton(
                    heroTag: 'Subjects Save',
                    foregroundColor: getFABIconForegroundColor(context),
                    backgroundColor: getFABIconBackgroundColor(context),
                    child: Icon(Icons.save),
                    onPressed: () async {
                      await _dbService
                          .updateGroupSubjectsOrder(
                        _groupStatus.group.docId,
                        _tempSubjectMetadatas,
                      )
                          .then((_) {
                        setState(() {
                          _orderChanged = false;
                        });
                        Fluttertoast.showToast(
                          msg: 'Successfully updated subjects order',
                          toastLength: Toast.LENGTH_LONG,
                        );
                      }).catchError((_) {
                        Fluttertoast.showToast(
                          msg: 'Failed to update subjects order',
                          toastLength: Toast.LENGTH_LONG,
                        );
                      });
                    },
                  ),
                ),
                Visibility(
                  visible: _orderChanged,
                  child: SizedBox(height: 20.0),
                ),
                FloatingActionButton(
                  heroTag: 'Subjects Add',
                  foregroundColor: getFABIconForegroundColor(context),
                  backgroundColor: getFABIconBackgroundColor(context),
                  child: Icon(Icons.add),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        GlobalKey<FormState> formKey = GlobalKey<FormState>();

                        return AddSubjectDialog(formKey: formKey);
                      },
                    );
                  },
                ),
              ],
            ),
            body: ReorderableListView(
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  _orderChanged = true;

                  String subjectMetadata = _tempSubjectMetadatas[oldIndex];

                  _tempSubjectMetadatas.removeAt(oldIndex);

                  if (newIndex >= _tempSubjectMetadatas.length) {
                    _tempSubjectMetadatas.add(subjectMetadata);
                  } else {
                    _tempSubjectMetadatas.insert(newIndex, subjectMetadata);
                  }
                });
              },
              children: _generateSubjects(),
            ),
          );
  }
}
