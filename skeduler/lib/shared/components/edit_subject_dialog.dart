import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/subject.dart';
import 'package:skeduler/services/database_service.dart';

class EditSubjectDialog extends StatefulWidget {
  final Subject subject;

  EditSubjectDialog({
    Key key,
    this.subject,
  }) : super(key: key);

  @override
  _EditSubjectDialogState createState() => _EditSubjectDialogState();
}

class _EditSubjectDialogState extends State<EditSubjectDialog> {
  String _newSubjectName;
  String _newSubjectNickname;
  GlobalKey<FormState> _formKey;

  @override
  void initState() {
    _newSubjectName = widget.subject.name;
    _newSubjectNickname = widget.subject.nickname;
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

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
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                border: InputBorder.none,
                enabled: false,
                hintText: widget.subject.docId == null
                    ? 'Subject ID'
                    : 'ID : ' + widget.subject.docId,
                hintStyle: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
            TextFormField(
              initialValue: _newSubjectNickname,
              decoration: InputDecoration(
                hintText: 'Subject short form (optional)',
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
              onChanged: (value) => _newSubjectNickname = value.trim(),
              validator: (value) => null,
            ),
            TextFormField(
              initialValue: _newSubjectName,
              decoration: InputDecoration(
                hintText: 'Subject full name',
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
              onChanged: (value) => _newSubjectName = value.trim(),
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
            if (_formKey.currentState.validate()) {
              OperationStatus status = await dbService.updateGroupSubject(
                groupStatus.group.docId,
                Subject(
                  docId: widget.subject.docId,
                  name: _newSubjectName,
                  nickname: _newSubjectNickname,
                ),
              );

              if (status.completed) {
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
    );
  }
}
