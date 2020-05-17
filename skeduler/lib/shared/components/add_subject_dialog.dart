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
  String _newSubjectId;
  String _newSubjectName;
  String _newSubjectNickname;

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
                border: InputBorder.none,
                enabled: false,
                hintText: _newSubjectId == null || _newSubjectId.trim() == ''
                    ? 'ID : (automated)'
                    : 'ID : ' + _newSubjectId,
                hintStyle: TextStyle(
                  fontSize: 15.0,
                ),
              ),
            ),
            TextFormField(
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
              decoration: InputDecoration(
                hintText: 'Subject full name',
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _newSubjectId = value
                      .trim()
                      .replaceAll(RegExp('[^A-Za-z0-9]'), '')
                      .toLowerCase();

                  _newSubjectName = value.trim();
                });
              },
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
