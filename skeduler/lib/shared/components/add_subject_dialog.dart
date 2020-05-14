import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/subject.dart';
import 'package:skeduler/services/database_service.dart';

class AddSubjectDialog extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const AddSubjectDialog({
    Key key,
    @required this.formKey,
  }) : super(key: key);

  @override
  _AddSubjectDialogState createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  String newSubjectName;
  String newSubjectNickname;

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return AlertDialog(
      title: Text(
        'New subject',
        style: TextStyle(fontSize: 16.0),
      ),
      content: Form(
        key: widget.formKey,
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
              onChanged: (value) => newSubjectNickname = value.trim(),
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
              onChanged: (value) => newSubjectName = value.trim(),
              validator: (value) => value == null || value.trim() == ''
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
            if (widget.formKey.currentState.validate()) {
              Navigator.of(context).maybePop();
              await dbService
                  .updateGroupSubjects(
                groupStatus.group.docId,
                groupStatus.group.subjects,
              )
                  .then((value) async {
                if (value) {
                  groupStatus.group.subjects.add(Subject(
                    name: newSubjectName,
                    nickname: newSubjectNickname,
                  ));

                  String returnMsg = await dbService.addGroupSubject(
                    groupStatus.group.docId,
                    Subject(
                      name: newSubjectName,
                      nickname: newSubjectNickname,
                    ),
                  );

                  setState(() {
                    groupStatus.hasChanges = false;
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
  }
}
