import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/user.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';
import 'package:skeduler/shared/label_text_input.dart';

class ChangeUserData extends StatefulWidget {
  @override
  _ChangeUserDataState createState() => _ChangeUserDataState();
}

class _ChangeUserDataState extends State<ChangeUserData> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    DatabaseService dbs = Provider.of<DatabaseService>(context);

    TextEditingController _controller = TextEditingController();
    _controller.text = user != null ? user.name : '';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 10.0,
      ),
      child: Form(
        child: Column(
          children: <Widget>[
            LabelTextInput(
              controller: _controller,
              formKey: _formKey,
              label: 'Name',
              hintText: user != null ? user.name : '',
              validator: (value) {
                if (value == null || value.trim() == '') {
                  return 'Name cannot be empty';
                } else if (value.length > 30) {
                  return 'Name must be less than 30 characters';
                } else {
                  return null;
                }
              },
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    _controller.text = user.name;
                    unfocus();
                  },
                  child: Text('Cancel'),
                ),
                FlatButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      bool hasConn = await checkInternetConnection();
                      if (hasConn) {
                        dbs.updateUserData(name: _controller.text);
                        _controller.text = user.name;
                      } else {
                        Fluttertoast.showToast(
                          msg: 'Please check your internet connection',
                          toastLength: Toast.LENGTH_LONG,
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                        );
                        _controller.text = user.name;
                      }
                      unfocus();
                    }
                  },
                  child: Text('Update'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
