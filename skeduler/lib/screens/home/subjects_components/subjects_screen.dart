import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/home_drawer.dart';
import 'package:skeduler/models/auxiliary/drawer_enum.dart';
import 'package:skeduler/models/auxiliary/route_arguments.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/screens/home/subjects_components/subject_list_tile.dart';
import 'package:skeduler/shared/widgets/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class SubjectsScreen extends StatefulWidget {
  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DatabaseService _dbService;
  GroupStatus _groupStatus;

  bool _orderChanged;
  List<String> _tempSubjectMetadatas;

  List<Widget> _generateSubjects({@required bool canReorder}) {
    List<Widget> widgets = [];

    if (_groupStatus.subjects.length == 0) {
      widgets.add(
        ListTile(
          key: UniqueKey(),
          leading: Icon(
            Icons.class_,
            color: Colors.grey,
          ),
          title: Text(
            'No subject',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          subtitle: Text(
            'can be found in this group',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    } else if (_orderChanged && canReorder) {
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
            key: _scaffoldKey,
            appBar: AppBar(
              title: AppBarTitle(
                title: _groupStatus.group.name,
                alternateTitle: 'Subjects',
                subtitle: 'Subjects',
              ),
            ),
            drawer: HomeDrawer(DrawerEnum.subjects),
            floatingActionButton: _groupStatus.me.role == MemberRole.owner ||
                    _groupStatus.me.role == MemberRole.admin
                ? Column(
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
                            _scaffoldKey.currentState.showSnackBar(
                                LoadingSnackBar(
                                    context, 'Updating subjects order . . .'));

                            OperationStatus status =
                                await _dbService.updateGroupSubjectsOrder(
                              _groupStatus.group.docId,
                              _tempSubjectMetadatas,
                            );

                            if (status.completed) {
                              Fluttertoast.showToast(
                                msg: status.message,
                                toastLength: Toast.LENGTH_LONG,
                              );

                              _scaffoldKey.currentState.hideCurrentSnackBar();
                            }

                            if (status.success) {
                              setState(() => _orderChanged = false);
                            }
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
                          Navigator.of(context).pushNamed(
                            '/subjects/addSubject',
                            arguments: RouteArgs(),
                          );
                        },
                      ),
                    ],
                  )
                : null,
            body: _groupStatus.me.role == MemberRole.owner ||
                    _groupStatus.me.role == MemberRole.admin
                ? ReorderableListView(
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        String subjectMetadata =
                            _tempSubjectMetadatas[oldIndex];

                        _tempSubjectMetadatas.removeAt(oldIndex);

                        if (newIndex >= _tempSubjectMetadatas.length) {
                          _tempSubjectMetadatas.add(subjectMetadata);
                        } else {
                          _tempSubjectMetadatas.insert(
                              newIndex, subjectMetadata);
                        }

                        bool sameOrder = true;
                        for (int i = 0; i < _tempSubjectMetadatas.length; i++) {
                          if (_tempSubjectMetadatas[i] !=
                              _groupStatus.group.subjectMetadatas[i]) {
                            sameOrder = false;
                          }
                        }

                        _orderChanged = !sameOrder;
                      });
                    },
                    children: _generateSubjects(canReorder: true),
                  )
                : ListView(
                    children: _generateSubjects(canReorder: false),
                  ),
          );
  }
}
