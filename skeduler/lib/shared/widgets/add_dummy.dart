import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/firestore/group.dart';
import 'package:skeduler/models/firestore/member.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/widgets/label_text_input.dart';
import 'package:skeduler/shared/widgets/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/simple_widgets.dart';

class AddDummy extends StatefulWidget {
  @override
  _AddDummyState createState() => _AddDummyState();
}

class _AddDummyState extends State<AddDummy> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKeyName = GlobalKey<FormState>();

  String _newDummyId;
  String _newDummyName;
  String _newDummyNickname;

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
                    subtitle: 'Add dummy',
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
                title: groupStatus.group == null
                    ? 'Group'
                    : groupStatus.group.name,
                alternateTitle: 'Group',
                subtitle: 'Add dummy',
              ),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // Cancel changes
                FloatingActionButton(
                  heroTag: 'Add Dummy Cancel',
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
                  heroTag: 'Add Dummy Confirm',
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    unfocus();

                    if (_formKeyName.currentState.validate()) {
                      _scaffoldKey.currentState.showSnackBar(
                        LoadingSnackBar(context, 'Adding dummy . . .'),
                      );

                      OperationStatus status = await dbService.addDummyToGroup(
                        groupDocId: groupStatus.group.docId,
                        dummy: Member(
                          docId: _newDummyId.trim(),
                          name: _newDummyName.trim(),
                          nickname: _newDummyNickname == null ||
                                  _newDummyNickname.trim() == ''
                              ? _newDummyName.trim()
                              : _newDummyNickname.trim(),
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
                      hintText: _newDummyId == null || _newDummyId.trim() == ''
                          ? 'automated'
                          : _newDummyId,
                      label: 'ID',
                    ),
                  ),

                  // Nickname
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: LabelTextInput(
                      initialValue: _newDummyNickname,
                      hintText: 'Optional',
                      label: 'Nickname',
                      valSetText: (value) => _newDummyNickname = value,
                    ),
                  ),

                  // Name
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: LabelTextInput(
                      initialValue: _newDummyName,
                      hintText: 'Required',
                      label: 'Name',
                      valSetText: (value) {
                        setState(() {
                          _newDummyName = value;

                          _newDummyId = value
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
