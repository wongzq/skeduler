import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/label_text_input.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';

class AddDummy extends StatefulWidget {
  @override
  _AddDummyState createState() => _AddDummyState();
}

class _AddDummyState extends State<AddDummy> {
  String _newDummyName;
  GlobalKey<FormState> _formKeyName = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    ValueNotifier<String> groupDocId =
        Provider.of<ValueNotifier<String>>(context);

    return StreamBuilder(
      stream: dbService.getGroup(groupDocId.value),
      builder: (context, snapshot) {
        Group group = snapshot != null ? snapshot.data : null;

        return group == null
            ? Loading()
            : Scaffold(
                appBar: AppBar(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        group.name,
                        style: textStyleAppBarTitle,
                      ),
                      Text(
                        'Add dummy',
                        style: textStyleBody,
                      )
                    ],
                  ),
                ),
                floatingActionButton: Row(
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
                              .inviteDummyToGroup(
                            groupDocId: groupDocId.value,
                            newDummyName: _newDummyName,
                          )
                              .then((errorMsg) {
                            if (errorMsg == null) {
                              Fluttertoast.showToast(
                                msg: _newDummyName + ' has been invited',
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
                body: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => unfocus(),
                  child: Column(
                    children: <Widget>[
                      /// Required fields
                      /// Email
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: LabelTextInput(
                          initialValue: _newDummyName,
                          hintText: 'Required',
                          label: 'Name',
                          valSetText: (value) {
                            _newDummyName = value;
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
      },
    );
  }
}
