import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/group_data/group.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/components/loading.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/ui_settings.dart';
import 'package:skeduler/shared/widgets.dart';
import 'package:skeduler/shared/widgets.dart';

class AddSubject extends StatefulWidget {
  @override
  _AddSubjectState createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKeyName = GlobalKey<FormState>();

  String _newSubjectId;
  String _newSubjectName;
  String _newSubjectNickname;

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = Provider.of<DatabaseService>(context);
    GroupStatus groupStatus = Provider.of<GroupStatus>(context);

    return groupStatus.group == null
        ? Loading()
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: AppBarTitle(
                title: groupStatus.group.name,
                alternateTitle: 'Add subject',
                subtitle: 'Add subject',
              ),
            ),
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // Cancel changes
                FloatingActionButton(
                  heroTag: 'Add Subject Cancel',
                  backgroundColor: Colors.red,
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),

                SizedBox(width: 20.0),

                FloatingActionButton(
                  heroTag: 'Add Subject Confirm',
                  backgroundColor: Colors.green,
                  onPressed: () async {
                    unfocus();

                    if (_formKeyName.currentState.validate()) {
                      _scaffoldKey.currentState.showSnackBar(
                        LoadingSnackBar(context, 'Adding subject . . .'),
                      );
                    }
                  },
                ),
              ],
            ),
          );
  }
}
