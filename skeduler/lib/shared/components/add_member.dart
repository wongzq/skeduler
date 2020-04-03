import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group.dart';
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
  String _newMemberEmail;
  GlobalKey<FormState> _formKeyName = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);

    return StreamBuilder<Object>(
      stream: dbService.getGroup(groupDocId.value),
      builder: (context, snapshot) {
        Group group = snapshot != null ? snapshot.data : null;

        return group == null
            ? Loading()
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: getOriginThemeColorShade(group.colorShade),
                  iconTheme: getOriginThemeData(group.colorShade.themeId)
                      .primaryIconTheme,
                  textTheme: getOriginThemeData(group.colorShade.themeId)
                      .primaryTextTheme,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        group.name,
                        style: textStyleAppBarTitle,
                      ),
                      Text(
                        'Add member',
                        style: textStyleBody,
                      )
                    ],
                  ),
                ),
                body: Stack(
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => unfocus(),
                      child: Column(
                        children: <Widget>[
                          /// Required fields
                          /// Email
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: LabelTextInput(
                              initialValue: _newMemberEmail,
                              hintText: 'Required',
                              label: 'Email',
                              valueSetterText: (value) {
                                _newMemberEmail = value;
                              },
                              formKey: _formKeyName,
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

                    /// Editing mode
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20.0, right: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            /// Cancel changes
                            FloatingActionButton(
                              heroTag: 'Cancel',
                              backgroundColor: Colors.red,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(width: 20.0),

                            /// Confirm amd make changes
                            FloatingActionButton(
                              heroTag: 'Confirm',
                              backgroundColor: Colors.green,
                              onPressed: () async {
                                if (_formKeyName.currentState.validate()) {
                                  await dbService
                                      .addMemberToGroup(
                                    groupDocId: groupDocId.value,
                                    newMemberEmail: _newMemberEmail,
                                  )
                                      .then((errorMsg) {
                                    if (errorMsg == null) {
                                      Fluttertoast.showToast(
                                        msg: _newMemberEmail +
                                            ' added successfully',
                                        toastLength: Toast.LENGTH_LONG,
                                      );
                                      Navigator.of(context).pop();
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: errorMsg,
                                        toastLength: Toast.LENGTH_LONG,
                                      );
                                    }
                                  });
                                }
                              },
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
      },
    );
  }
}