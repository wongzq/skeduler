import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:skeduler/models/firestore/user.dart';
import 'package:skeduler/services/database_service.dart';
import 'package:skeduler/shared/functions.dart';

class ChangeUserData extends StatefulWidget {
  @override
  _ChangeUserDataState createState() => _ChangeUserDataState();
}

class _ChangeUserDataState extends State<ChangeUserData> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    DatabaseService dbService = Provider.of<DatabaseService>(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        GlobalKey<FormState> formKey = GlobalKey<FormState>();
        String newName = user.name;

        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                'Name',
              ),
              content: Form(
                key: formKey,
                child: TextFormField(
                  initialValue: user != null ? user.name : '',
                  onChanged: (value) {
                    newName = value.trim();
                  },
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
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('CANCEL'),
                  onPressed: () {
                    unfocus();
                    Navigator.of(context).maybePop();
                  },
                ),
                FlatButton(
                  child: Text('UPDATE'),
                  onPressed: () async {
                    if (formKey.currentState.validate()) {
                      unfocus();
                      if (await checkInternetConnection()) {
                        Navigator.of(context).maybePop();
                        newName = newName == null || newName.trim() == ''
                            ? user.name
                            : newName;
                        await dbService
                            .updateUserData(name: newName)
                            .then((_) {});
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Please check your internet connection');
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Name',
              style: TextStyle(fontSize: 15.0),
            ),
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Text(
                user != null ? user.name : '',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
