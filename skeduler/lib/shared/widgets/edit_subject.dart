import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/subject.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/widgets/label_text_input.dart';
import 'package:skeduler/shared/widgets/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class EditSubject extends StatefulWidget {
  final Subject subject;

  const EditSubject({Key key, @required this.subject}) : super(key: key);
  @override
  _EditSubjectState createState() => _EditSubjectState();
}

class _EditSubjectState extends State<EditSubject> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKeyName = GlobalKey<FormState>();

  String _newSubjectName;
  String _newSubjectNickname;

  @override
  void initState() {
    _newSubjectName = widget.subject.name;
    _newSubjectNickname = widget.subject.nickname;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Stack(
            children: <Widget>[
              Scaffold(
                appBar: AppBar(
                  title: AppBarTitle(
                    title: 'Group',
                    subtitle: 'Edit subject',
                  ),
                ),
              ),
              Loading(),
            ],
          )
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: AppBarTitle(
                title: groupStatus.group.name,
                alternateTitle: 'Group',
                subtitle: 'Edit subject',
              ),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // Cancel add subject
                FloatingActionButton(
                  heroTag: 'Edit Subject Cancel',
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
                  heroTag: 'Edit Subject Confirm',
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    unfocus();

                    if (_formKeyName.currentState.validate()) {
                      _scaffoldKey.currentState.showSnackBar(
                        LoadingSnackBar(context, 'Saving subject . . .'),
                      );

                      OperationStatus status =
                          await dbService.updateGroupSubject(
                        groupStatus.group.docId,
                        Subject(
                          docId: widget.subject.docId,
                          name: _newSubjectName.trim(),
                          nickname: _newSubjectNickname == null ||
                                  _newSubjectNickname.trim() == ''
                              ? _newSubjectName.trim()
                              : _newSubjectNickname.trim(),
                        ),
                      );

                      if (status.completed) {
                        _scaffoldKey.currentState.hideCurrentSnackBar();
                        Fluttertoast.showToast(msg: status.message);
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
                  // ID
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: LabelTextInput(
                      enabled: false,
                      hintText: widget.subject.docId,
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
