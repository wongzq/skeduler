import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/label_text_input.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';

class AddMember extends StatefulWidget {
  @override
  _AddMemberState createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  GlobalKey<FormState> _formKeyEmail = GlobalKey<FormState>();
  String _newMemberEmail;

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    groupStatus.group.name,
                    style: textStyleAppBarTitle,
                  ),
                  Text(
                    'Add member',
                    style: textStyleBody,
                  ),
                ],
              ),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // Cancel changes
                FloatingActionButton(
                  heroTag: 'Add Member Cancel',
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

                // Confirm amd make changes
                FloatingActionButton(
                  heroTag: 'Add Member Confirm',
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    if (_formKeyEmail.currentState.validate()) {
                      await dbService
                          .inviteMemberToGroup(
                        groupDocId: groupStatus.group.docId,
                        newMemberEmail: _newMemberEmail,
                      )
                          .then((errorMsg) {
                        if (errorMsg == null) {
                          Fluttertoast.showToast(
                            msg: _newMemberEmail + ' has been invited',
                            toastLength: Toast.LENGTH_LONG,
                          );
                          Navigator.of(context).maybePop();
                        } else {
                          Fluttertoast.showToast(
                            msg: errorMsg,
                            toastLength: Toast.LENGTH_LONG,
                          );
                        }
                      });
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
                  // Required fields
                  // ID
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: LabelTextInput(
                      initialValue: _newMemberEmail,
                      hintText: 'Required',
                      label: 'Email',
                      valSetText: (value) {
                        _newMemberEmail = value;
                      },
                      formKey: _formKeyEmail,
                      validator: (value) {
                        RegExp regExp = RegExp(
                            r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)");
                        return _newMemberEmail != null &&
                                _newMemberEmail.trim().length > 0 &&
                                regExp.hasMatch(_newMemberEmail)
                            ? null
                            : 'Invalid email address';
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
