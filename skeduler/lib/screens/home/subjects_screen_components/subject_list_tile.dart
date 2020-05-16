import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/models/group_data/subject.dart';
import 'package:skeduler/services/database_service.dart';

enum SubjectOption { edit, remove }

class SubjectListTile extends StatelessWidget {
  final Subject subject;

  const SubjectListTile({
    Key key,
    @required this.subject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.class_),
          title: Text(subject.display ?? ''),
          subtitle: Text(subject.name ?? ''),
          trailing: PopupMenuButton<SubjectOption>(
            itemBuilder: (context) {
              return [
                PopupMenuItem<SubjectOption>(
                  value: SubjectOption.edit,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.edit),
                      SizedBox(width: 10.0),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem<SubjectOption>(
                  value: SubjectOption.remove,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete),
                      SizedBox(width: 10.0),
                      Text('Remove'),
                    ],
                  ),
                ),
              ];
            },
            onSelected: (option) {
              switch (option) {
                case SubjectOption.edit:
                  showDialog(
                      context: context,
                      builder: (context) {
                        GlobalKey<FormState> formKey = GlobalKey<FormState>();
                        String newSubjectName = subject.name;
                        String newSubjectNickname = subject.nickname;

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
                                  initialValue: newSubjectNickname,
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
                                  initialValue: newSubjectName,
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

                                  await dbService
                                      .updateGroupSubject(
                                    groupStatus.group.docId,
                                    Subject(
                                      docId: subject.docId,
                                      name: newSubjectName,
                                      nickname: newSubjectNickname,
                                    ),
                                  )
                                      .then((_) {
                                    Fluttertoast.showToast(
                                      msg: 'Successfully updated subject',
                                      toastLength: Toast.LENGTH_LONG,
                                    );
                                  }).catchError((_) {
                                    Fluttertoast.showToast(
                                      msg: 'Failed to update subject',
                                      toastLength: Toast.LENGTH_LONG,
                                    );
                                  });
                                }
                              },
                            ),
                          ],
                        );
                      });
                  break;

                case SubjectOption.remove:
                  dbService.removeGroupSubject(
                      groupStatus.group.docId, subject);
                  break;
              }
            },
          ),
        ),
        Divider(height: 1.0),
      ],
    );
  }
}
