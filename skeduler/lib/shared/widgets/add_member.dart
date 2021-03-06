import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/auxiliary/origin_theme.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/widgets/label_text_input.dart';
import 'package:skeduler/shared/widgets/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class AddMember extends StatefulWidget {
  @override
  _AddMemberState createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKeyEmail = GlobalKey<FormState>();
  String _newMemberEmail;

  @override
  Widget build(BuildContext context) {
    OriginTheme originTheme = Provider.of<OriginTheme>(context);
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Stack(
            children: <Widget>[
              Scaffold(
                appBar: AppBar(
                  title: AppBarTitle(
                    title: 'Group',
                    subtitle: 'Add member',
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
                subtitle: 'Add member',
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
                    unfocus();

                    if (_formKeyEmail.currentState.validate()) {
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          content: Row(
                            children: <Widget>[
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  originTheme.accentColor,
                                ),
                              ),
                              SizedBox(width: 20.0),
                              Text(
                                'Inviting member . . .',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .primaryTextTheme
                                      .bodyText1
                                      .color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      OperationStatus status =
                          await dbService.inviteMemberToGroup(
                        groupDocId: groupStatus.group.docId,
                        newMemberEmail: _newMemberEmail,
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
                  // Required fields
                  // ID
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
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
