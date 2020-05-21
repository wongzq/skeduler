import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/subject.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/widgets/label_text_input.dart';
import 'package:skeduler/shared/widgets/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class AddSubject extends StatefulWidget {
  @override
  _AddSubjectState createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKeyName = GlobalKey<FormState>();

  String _newSubjectId;
  String _newSubjectName;
  String _newSubjectNickname;

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Loading()
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: AppBarTitle(
                title: groupStatus.group.name,
                alternateTitle: 'Add subject',
                subtitle: 'Add subject',
              ),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // Cancel add subject
                FloatingActionButton(
                  heroTag: 'Add Subject Cancel',
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                ),

                SizedBox(width: 20.0),

                // Confirm add subject
                FloatingActionButton(
                  heroTag: 'Add Subject Confirm',
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    unfocus();

                    if (_formKeyName.currentState.validate()) {
                      _scaffoldKey.currentState.showSnackBar(
                        LoadingSnackBar(context, 'Adding subject . . .'),
                      );

                      OperationStatus status = await dbService.addGroupSubject(
                        groupStatus.group.docId,
                        Subject(
                          docId: _newSubjectId.trim(),
                          name: _newSubjectName.trim(),
                          nickname: _newSubjectNickname == null ||
                                  _newSubjectNickname.trim() == ''
                              ? _newSubjectName.trim()
                              : _newSubjectNickname.trim(),
                        ),
                      );

                      if (status.completed) {
                        _scaffoldKey.currentState.hideCurrentSnackBar();
                        Fluttertoast.showToast(
                          msg: status.message,
                          toastLength: Toast.LENGTH_LONG,
                        );
                      }

                      if (status.success) {
                        Navigator.of(context).maybePop();
                      }
                    }
                  },
                ),
              ],
            ),
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => unfocus(),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: LabelTextInput(
                      enabled: false,
                      hintText:
                          _newSubjectId == null || _newSubjectId.trim() == ''
                              ? 'automated'
                              : _newSubjectId,
                      label: 'ID',
                    ),
                  ),

                  // Nickname
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: LabelTextInput(
                      initialValue: _newSubjectNickname,
                      hintText: 'Optional',
                      label: 'Nickname',
                      valSetText: (value) => _newSubjectNickname = value,
                    ),
                  ),

                  // Name
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: LabelTextInput(
                      initialValue: _newSubjectName,
                      hintText: 'Required',
                      label: 'Name',
                      valSetText: (value) {
                        setState(() {
                          _newSubjectName = value;

                          _newSubjectId = value
                              .trim()
                              .replaceAll(RegExp('[^A-Za-z0-9]'), '')
                              .toLowerCase();
                        });
                      },
                      formKey: _formKeyName,
                      validator: (value) {
                        return value != null && value.trim() != ''
                            ? null
                            : 'Name cannot be empty';
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
